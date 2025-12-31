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

    assert_equal File.basename(file.path), hash[:fileName]
    assert_equal Base64.strict_encode64("hello world"), hash[:content]
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

    assert_equal File.basename(file.path), hash[:fileName]
    assert_equal Base64.strict_encode64("hello path"), hash[:content]
  ensure
    file&.unlink
  end

  def test_initialization_with_url
    url = "https://example.com/image.png"
    attachment = AutosendRb::Entities::Attachment.new(file: url)
    hash = attachment.to_h

    assert_equal "image.png", hash[:fileName]
    assert_equal url, hash[:fileUrl]
    assert_nil hash[:content]
  end

  def test_invalid_file_path
    assert_raises(ArgumentError) do
      AutosendRb::Entities::Attachment.new(file: "/non/existent/path.txt").to_h
    end
  end

  def test_initialization_with_hash
    content = "raw content"
    filename = "test.txt"
    attachment = AutosendRb::Entities::Attachment.new(file: { content: content, filename: filename })
    hash = attachment.to_h

    assert_equal filename, hash[:fileName]
    assert_equal Base64.strict_encode64(content), hash[:content]
    assert_nil hash[:contentType]
  end

  def test_initialization_with_hash_and_content_type
    content = "raw content"
    filename = "test.pdf"
    content_type = "application/pdf"
    attachment = AutosendRb::Entities::Attachment.new(
      file: { content: content, filename: filename, content_type: content_type }
    )
    hash = attachment.to_h

    assert_equal filename, hash[:fileName]
    assert_equal Base64.strict_encode64(content), hash[:content]
    assert_equal content_type, hash[:contentType]
  end

  def test_initialization_with_invalid_hash
    assert_raises(ArgumentError) do
      AutosendRb::Entities::Attachment.new(file: { content: "foo" })
    end

    assert_raises(ArgumentError) do
      AutosendRb::Entities::Attachment.new(file: { filename: "foo.txt" })
    end

    assert_raises(ArgumentError) do
      AutosendRb::Entities::Attachment.new(file: { content: "", filename: "foo.txt" })
    end
  end

  def test_coerce_with_hash
    # Case 1: Hash representing a raw file
    raw_hash = { content: "hello", filename: "hello.txt", description: "desc" }
    attachment = AutosendRb::Entities::Attachment.coerce(raw_hash)

    assert_equal "hello.txt", attachment.file[:filename]
    assert_equal "desc", attachment.description

    # Case 2: Hash representing the Attachment object structure (legacy/wrapper)
    wrapper_hash = { file: "https://example.com/img.png", description: "desc" }
    attachment = AutosendRb::Entities::Attachment.coerce(wrapper_hash)

    assert_equal "https://example.com/img.png", attachment.file
    assert_equal "desc", attachment.description
  end

  def test_description_preservation
    desc = "A nice file"

    # File object
    file = Tempfile.new("test.txt")
    att1 = AutosendRb::Entities::Attachment.new(file: file, description: desc)
    assert_equal desc, att1.to_h[:description]
    file.close
    file.unlink

    # URL
    att2 = AutosendRb::Entities::Attachment.new(file: "http://example.com", description: desc)
    assert_equal desc, att2.to_h[:description]

    # Hash
    att3 = AutosendRb::Entities::Attachment.new(
      file: { content: "a", filename: "a" },
      description: desc
    )
    assert_equal desc, att3.to_h[:description]
  end

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

  def test_attachment_for_tempfile_with_description_with_api_schema
    file = Tempfile.new("test.txt")
    file.write("api schema content")
    file.rewind

    attachment = AutosendRb::Entities::Attachment.coerce({ file: file, description: "API Schema Test" })
    hash = attachment.to_h

    expected_hash = {
      fileName: File.basename(file.path),
      content: Base64.strict_encode64("api schema content"),
      description: "API Schema Test"
    }

    assert_equal expected_hash, hash
  ensure
    file.close
    file.unlink
  end

  def test_attachment_for_tempfile_with_api_schema
    file = Tempfile.new("test.txt")
    file.write("api schema content")
    file.rewind

    attachment = AutosendRb::Entities::Attachment.coerce(file)
    hash = attachment.to_h

    expected_hash = {
      fileName: File.basename(file.path),
      content: Base64.strict_encode64("api schema content")
    }

    assert_equal expected_hash, hash
  ensure
    file.close
    file.unlink
  end

  def test_attachment_for_url_with_api_schema
    url = "https://sample-files.com/downloads/documents/pdf/basic-text.pdf"
    attachment = AutosendRb::Entities::Attachment.coerce({ file: url, description: "API Schema URL Test" })
    hash = attachment.to_h

    expected_hash = {
      fileName: "basic-text.pdf",
      fileUrl: url,
      description: "API Schema URL Test"
    }

    assert_equal expected_hash, hash
  end

  def test_attachment_for_local_file_with_api_schema
    url = "./test/fixtures/img.jpeg"
    attachment = AutosendRb::Entities::Attachment.coerce({ file: url, description: "API Schema URL Test" })
    hash = attachment.to_h

    expected_hash = {
      fileName: "img.jpeg",
      content: Base64.strict_encode64(File.read(url)),
      description: "API Schema URL Test"
    }

    assert_equal expected_hash, hash
  end

  def test_attachment_for_hash_with_api_schema
    content = "API schema raw content"
    filename = "api_schema.txt"
    attachment = AutosendRb::Entities::Attachment.coerce({ content: content, filename: filename,
                                                           content_type: "text/plain",
                                                           description: "API Schema Hash Test" })
    hash = attachment.to_h

    expected_hash = {
      fileName: filename,
      content: Base64.strict_encode64(content),
      contentType: "text/plain",
      description: "API Schema Hash Test"
    }

    assert_equal expected_hash, hash
  end
end
