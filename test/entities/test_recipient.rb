# frozen_string_literal: true

require "test_helper"

class TestRecipient < Minitest::Test
  def test_initialization
    recipient = AutosendRb::Entities::Recipient.new(email: "test@example.com", name: "Test")
    assert_equal "test@example.com", recipient.email
    assert_equal "Test", recipient.name
  end

  def test_validation
    assert_raises(ArgumentError) { AutosendRb::Entities::Recipient.new(email: "") }
    assert_raises(TypeError) { AutosendRb::Entities::Recipient.new(email: 123) }
  end

  def test_coerce_hash
    recipient = AutosendRb::Entities::Recipient.coerce({ email: "test@example.com", name: "Test" })
    assert_instance_of AutosendRb::Entities::Recipient, recipient
    assert_equal "test@example.com", recipient.email
  end

  def test_coerce_object
    original = AutosendRb::Entities::Recipient.new(email: "test@example.com")
    coerced = AutosendRb::Entities::Recipient.coerce(original)
    assert_same original, coerced
  end
end
