# frozen_string_literal: true

require "test_helper"

class TestSendEmailRequest < Minitest::Test
  def setup
    @valid_recipient = { email: "test@example.com", name: "Test User" }
  end

  def test_initialization_with_build
    request = AutosendRb::Requests::SendEmail.build do |r|
      r.subject = "Hello"
      r.to = @valid_recipient
      r.from = @valid_recipient
      r.body = { html: "<h1>Hi</h1>" }
    end

    assert_equal "Hello", request.subject
    assert_equal "test@example.com", request.to.email
  end

  def test_initialization_with_kwargs
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      to: @valid_recipient,
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>" }
    )

    assert_equal "Hello", request.subject
    assert_equal "test@example.com", request.to.email
  end

  def test_validation_success
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      to: @valid_recipient,
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>" }
    )

    assert_nil request.validate!
  end

  def test_validation_missing_recipients
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>" }
    )

    error = assert_raises(ArgumentError) { request.validate! }
    assert_match(/to and from details are required/, error.message)
  end

  def test_validation_missing_body
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      to: @valid_recipient,
      from: @valid_recipient
    )

    error = assert_raises(ArgumentError) { request.validate! }
    assert_match(/body is required/, error.message)
  end

  def test_validation_template_conflict
    request = AutosendRb::Requests::SendEmail.new(
      to: @valid_recipient,
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>", template_id: "tmpl_123" }
    )

    error = assert_raises(ArgumentError) { request.validate! }
    assert_match(%r{cannot provide html/text when template_id is present}, error.message)
  end

  def test_validation_missing_subject_without_template
    request = AutosendRb::Requests::SendEmail.new(
      to: @valid_recipient,
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>" }
    )

    error = assert_raises(ArgumentError) { request.validate! }
    assert_match(/subject is required when not using a template/, error.message)
  end

  def test_attachments_validation
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      to: @valid_recipient,
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>" }
    )

    # Mock 21 attachments
    21.times { request.add_attachment(File.expand_path(__FILE__)) }

    error = assert_raises(ArgumentError) { request.validate! }
    assert_match(/maximum 20 attachments allowed/, error.message)
  end

  def test_to_h_structure
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      to: @valid_recipient,
      from: @valid_recipient,
      body: { html: "<h1>Hi</h1>" }
    )

    hash = request.to_h
    assert_equal "Hello", hash[:subject]
    assert_equal "test@example.com", hash[:to][:email]
    assert_equal "<h1>Hi</h1>", hash[:html]
  end

  def test_against_api_for_html_with_file_attachment_schema
    f1 = Tempfile.new(["test1", ".txt"])
    f1.write("This is a test file.")
    f1.rewind
    request = AutosendRb::Requests::SendEmail.new(
      subject: "Hello",
      to: @valid_recipient,
      from: @valid_recipient,
      reply_to: @valid_recipient,
      body: { html: "<h1>Hi</h1>", text: "Hi" },
      attachments: [{ file: f1, description: "Test File" },
                    { file: File.open("test/fixtures/img.jpeg"), description: "Catto" }],
      unsubscribe_group_id: "group_123",
      dynamic_data: { user_id: 123 }
    )

    expected_hash = {
      subject: "Hello",
      to: { email: "test@example.com", name: "Test User" },
      from: { email: "test@example.com", name: "Test User" },
      replyTo: { email: "test@example.com", name: "Test User" },
      html: "<h1>Hi</h1>",
      text: "Hi",
      attachments: [
        { filename: File.basename(f1.path),
          content: Base64.strict_encode64("This is a test file."),
          description: "Test File" },
        { filename: "img.jpeg",
          content: Base64.strict_encode64(File.read("test/fixtures/img.jpeg")),
          description: "Catto" }
      ],
      unsubscribeGroupId: "group_123",
      dynamicData: { user_id: 123 }
    }
    assert_equal expected_hash, request.to_h
  end

  def test_against_api_for_template_id_with_url_attachment_schema
    request = AutosendRb::Requests::SendEmail.new(
      to: @valid_recipient,
      from: @valid_recipient,
      reply_to: @valid_recipient,
      body: { template_id: "tmpl_123" },
      attachments: ["https://sample-files.com/downloads/documents/pdf/basic-text.pdf",
                    { file: "test/fixtures/img.jpeg", description: "Catto" }],
      unsubscribe_group_id: "group_123",
      dynamic_data: { user_id: 123 }
    )

    expected_hash = {
      to: { email: "test@example.com", name: "Test User" },
      from: { email: "test@example.com", name: "Test User" },
      replyTo: { email: "test@example.com", name: "Test User" },
      templateId: "tmpl_123",
      attachments: [
        { filename: "basic-text.pdf",
          fileUrl: "https://sample-files.com/downloads/documents/pdf/basic-text.pdf" },
        { filename: "img.jpeg",
          content: Base64.strict_encode64(File.read("test/fixtures/img.jpeg")),
          description: "Catto" }
      ],
      unsubscribeGroupId: "group_123",
      dynamicData: { user_id: 123 }
    }
    assert_equal expected_hash, request.to_h
  end
end
