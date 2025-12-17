# frozen_string_literal: true

require "test_helper"

class TestBody < Minitest::Test
  def test_initialization
    body = AutosendRb::Entities::Body.new(html: "<h1>Hi</h1>")
    assert_equal "<h1>Hi</h1>", body.html
  end

  def test_validation_success
    body = AutosendRb::Entities::Body.new(html: "<h1>Hi</h1>")
    assert_nil body.validate!

    body = AutosendRb::Entities::Body.new(template_id: "tmpl_123")
    assert_nil body.validate!
  end

  def test_validation_conflict
    body = AutosendRb::Entities::Body.new(html: "<h1>Hi</h1>", template_id: "tmpl_123")
    error = assert_raises(ArgumentError) { body.validate! }
    assert_match(/cannot provide html\/text when template_id is present/, error.message)
  end

  def test_validation_missing_content
    body = AutosendRb::Entities::Body.new
    error = assert_raises(ArgumentError) { body.validate! }
    assert_match(/html or text is required/, error.message)
  end
end
