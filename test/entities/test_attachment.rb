# frozen_string_literal: true

require "test_helper"
require "tempfile"

class TestAttachment < Minitest::Test
  def test_initialization_with_file
    file = Tempfile.new("test.txt")
    file.write("hello world")
    file.rewind

    attachment = AutosendRb::Entities::Attachment.new(file: file)
    hash = attachment.to_h

    assert_equal File.basename(file.path), hash[:filename]
    assert_equal Base64.encode64("hello world"), hash[:content]
  ensure
    file&.close
    file&.unlink
  end

  def test_initialization_with_local_path
    file = Tempfile.new("test_path.txt")
    file.write("hello path")
    file.close

    attachment = AutosendRb::Entities::Attachment.new(file: file.path)
    hash = attachment.to_h

    assert_equal File.basename(file.path), hash[:filename]
    assert_equal Base64.encode64("hello path"), hash[:content]
  ensure
    file&.unlink
  end

  def test_initialization_with_url
    url = "https://example.com/image.png"
    attachment = AutosendRb::Entities::Attachment.new(file: url)
    hash = attachment.to_h

    assert_equal "image.png", hash[:filename]
    assert_equal url, hash[:fileUrl]
    assert_nil hash[:content]
  end

  def test_invalid_file_path
    assert_raises(ArgumentError) do
      AutosendRb::Entities::Attachment.new(file: "/non/existent/path.txt").to_h
    end
  end
end
