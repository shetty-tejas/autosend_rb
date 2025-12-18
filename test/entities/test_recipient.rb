# frozen_string_literal: true

require "test_helper"

class TestRecipient < Minitest::Test
  def test_initialization
    recipient = AutosendRb::Entities::Recipient.new(email: "test@example.com", name: "Test")
    assert_equal "test@example.com", recipient.email
    assert_equal "Test", recipient.name
    assert_nil recipient.dynamic_data
  end

  def test_initialization_with_dynamic_data
    dynamic_data = { "key" => "value" }
    recipient = AutosendRb::Entities::Recipient.new(email: "test@example.com", dynamic_data: dynamic_data)
    assert_equal dynamic_data, recipient.dynamic_data
  end

  def test_validation
    assert_raises(ArgumentError) { AutosendRb::Entities::Recipient.new(email: "") }
    assert_raises(TypeError) { AutosendRb::Entities::Recipient.new(email: 123) }
    assert_raises(TypeError) { AutosendRb::Entities::Recipient.new(email: "test@example.com", dynamic_data: "invalid") }
  end

  def test_to_h
    recipient = AutosendRb::Entities::Recipient.new(
      email: "test@example.com",
      name: "Test User",
      dynamic_data: { "code" => "123" }
    )
    expected = {
      email: "test@example.com",
      name: "Test User",
      dynamicData: { "code" => "123" }
    }
    assert_equal expected, recipient.to_h
  end

  def test_coerce_hash
    recipient = AutosendRb::Entities::Recipient.coerce({ email: "test@example.com", name: "Test",
                                                         dynamic_data: { "a" => 1 } })
    assert_instance_of AutosendRb::Entities::Recipient, recipient
    assert_equal "test@example.com", recipient.email
    assert_equal({ "a" => 1 }, recipient.dynamic_data)
  end

  def test_coerce_object
    original = AutosendRb::Entities::Recipient.new(email: "test@example.com")
    coerced = AutosendRb::Entities::Recipient.coerce(original)
    assert_same original, coerced
  end

  def test_recipient_with_api_schema
    recipient = AutosendRb::Entities::Recipient.coerce({ email: "test@example.com", name: "Test User",
                                                         dynamic_data: { "code" => "123" } })
    expected = {
      email: "test@example.com",
      name: "Test User",
      dynamicData: { "code" => "123" }
    }
    assert_equal expected, recipient.to_h
  end
end
