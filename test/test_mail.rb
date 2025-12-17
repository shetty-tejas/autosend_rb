# frozen_string_literal: true

require "test_helper"

class TestMail < Minitest::Test
  def test_send_with_block
    AutosendRb::Clients::Mail.expects(:send).with(instance_of(AutosendRb::Requests::SendEmail), raise_error: false)

    AutosendRb::Mail.send do |email|
      email.subject = "Test"
      email.from = { email: "sender@example.com" }
      email.to = { email: "recipient@example.com" }
    end
  end

  def test_send_with_payload
    payload = AutosendRb::Requests::SendEmail.new
    AutosendRb::Clients::Mail.expects(:send).with(payload, raise_error: false)

    AutosendRb::Mail.send(payload)
  end

  def test_send_with_both_payload_and_block
    payload = AutosendRb::Requests::SendEmail.new
    assert_raises(ArgumentError) do
      AutosendRb::Mail.send(payload) do |email|
        email.subject = "Test"
      end
    end
  end
end
