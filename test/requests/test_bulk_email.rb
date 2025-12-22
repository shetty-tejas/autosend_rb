# frozen_string_literal: true

require "test_helper"

class TestBulkEmail < Minitest::Test
  def setup
    @request = AutosendRb::Requests::BulkEmail.new
    @valid_recipient = { email: "test@example.com", name: "Test User" }
    @recipients = (1..100).map { |i| { email: "user#{i}@example.com", name: "User #{i}" } }
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

  def test_against_api_for_html_with_file_attachment_schema
    f1 = Tempfile.new(["test1", ".txt"])
    f1.write("This is a test file.")
    f1.rewind

    request = AutosendRb::Requests::BulkEmail.new(
      subject: "Hello",
      recipients: @recipients,
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
      recipients: @recipients,
      from: { email: "test@example.com", name: "Test User" },
      replyTo: { email: "test@example.com", name: "Test User" },
      html: "<h1>Hi</h1>",
      text: "Hi",
      attachments: [
        { fileName: File.basename(f1.path),
          content: Base64.strict_encode64("This is a test file."),
          description: "Test File" },
        { fileName: "img.jpeg",
          content: Base64.strict_encode64(File.read("test/fixtures/img.jpeg")),
          description: "Catto" }
      ],
      unsubscribeGroupId: "group_123",
      dynamicData: { user_id: 123 }
    }
    assert_equal expected_hash, request.to_h
  end

  def test_against_api_for_template_id_with_url_attachment_schema
    request = AutosendRb::Requests::BulkEmail.new(
      recipients: @recipients,
      from: @valid_recipient,
      reply_to: @valid_recipient,
      body: { template_id: "tmpl_123" },
      attachments: ["https://sample-files.com/downloads/documents/pdf/basic-text.pdf",
                    { file: "test/fixtures/img.jpeg", description: "Catto" }],
      unsubscribe_group_id: "group_123",
      dynamic_data: { user_id: 123 }
    )

    expected_hash = {
      recipients: @recipients,
      from: { email: "test@example.com", name: "Test User" },
      replyTo: { email: "test@example.com", name: "Test User" },
      templateId: "tmpl_123",
      attachments: [
        { fileName: "basic-text.pdf",
          fileUrl: "https://sample-files.com/downloads/documents/pdf/basic-text.pdf" },
        { fileName: "img.jpeg",
          content: Base64.strict_encode64(File.read("test/fixtures/img.jpeg")),
          description: "Catto" }
      ],
      unsubscribeGroupId: "group_123",
      dynamicData: { user_id: 123 }
    }
    assert_equal expected_hash, request.to_h
  end
end
