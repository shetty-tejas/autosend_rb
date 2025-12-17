# frozen_string_literal: true

require "test_helper"

class TestBulkEmail < Minitest::Test
  def setup
    @request = AutosendRb::Requests::BulkEmail.new
  end

  def test_initialization
    assert_empty @request.recipients
    assert_empty @request.attachments
  end

  def test_recipients_validation
    @request.recipients = (1..101).map { |i| { email: "user#{i}@example.com", name: "User #{i}" } }
    @request.from = { email: "sender@example.com" }

    error = assert_raises(ArgumentError) { @request.validate! }
    assert_match(/maximum 100 recipients allowed/, error.message)
  end

  def test_recipients_required
    @request.from = { email: "sender@example.com" }
    error = assert_raises(ArgumentError) { @request.validate! }
    assert_match(/recipients and from details are required/, error.message)
  end

  def test_to_h
    @request.from = { email: "sender@example.com" }
    @request.recipients = [
      { email: "u1@example.com", name: "U1", dynamic_data: { "id" => 1 } },
      { email: "u2@example.com", name: "U2" }
    ]
    @request.subject = "Bulk Subject"
    @request.body = { html: "<p>Hello</p>" }

    hash = @request.to_h

    assert_equal 2, hash[:recipients].size
    assert_equal "u1@example.com", hash[:recipients][0][:email]
    assert_equal({ "id" => 1 }, hash[:recipients][0][:dynamicData])
    assert_equal "Bulk Subject", hash[:subject]
  end
end
