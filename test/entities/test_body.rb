# frozen_string_literal: true

require "test_helper"

class TestBody < Minitest::Test
  def test_initialization
    body = AutosendRb::Entities::Body.new(html: "<h1>Hi</h1>", dynamic_data: { "name" => "User" })
    assert_equal "<h1>Hi</h1>", body.html
    assert_equal({ "name" => "User" }, body.dynamic_data)
  end

  def test_to_h
    body = AutosendRb::Entities::Body.new(
      html: "<p>Hi</p>",
      dynamic_data: { "name" => "User" }
    )
    expected = {
      html: "<p>Hi</p>",
      dynamicData: { "name" => "User" }
    }
    assert_equal expected, body.to_h
  end

  def test_coerce
    hash = { html: "<p>Hi</p>", dynamic_data: { "name" => "User" } }
    body = AutosendRb::Entities::Body.coerce(hash)
    
    assert_instance_of AutosendRb::Entities::Body, body
    assert_equal "<p>Hi</p>", body.html
    assert_equal({ "name" => "User" }, body.dynamic_data)
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
