# frozen_string_literal: true

require "test_helper"

class TestAttachment < Minitest::Test
  def test_initialization_with_description
    file = Tempfile.new("test")
    attachment = AutosendRb::Entities::Attachment.new(file: file, description: "Test File")
    assert_equal "Test File", attachment.description
  ensure
    file.close
    file.unlink
  end

  def test_to_h_with_description
    file = Tempfile.new("test.txt")
    file.write("content")
    file.rewind

    attachment = AutosendRb::Entities::Attachment.new(file: file, description: "My Description")
    hash = attachment.to_h

    assert_equal "My Description", hash[:description]
  ensure
    file.close
    file.unlink
  end

  def test_coerce_hash_with_description
    file = Tempfile.new("test.txt")
    hash = { file: file, description: "Coerced Description" }

    attachment = AutosendRb::Entities::Attachment.coerce(hash)

    assert_equal "Coerced Description", attachment.description
  ensure
    file.close
    file.unlink
  end
end
