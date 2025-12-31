# frozen_string_literal: true

require "test_helper"
require "rails"
require "action_mailer"
require "autosend_rb/railtie"

# Configure ActionMailer for testing
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :autosend

# Define a TestMailer for our integration tests
class IntegrationTestMailer < ActionMailer::Base
  default from: "sender@example.com"

  def html_text_msg(to, subject)
    mail(to: to, subject: subject) do |format|
      format.html { render html: "<p>HTML!</p>".html_safe }
      format.text { render plain: "text" }
    end
  end

  def text_only(to, subject)
    mail(to: to, subject: subject) do |format|
      format.text { render plain: "text" }
    end
  end

  def html_only(to, subject)
    mail(to: to, subject: subject) do |format|
      format.html { render html: "<p>HTML!</p>".html_safe }
    end
  end

  def with_attachment(to, subject)
    attachments["invoice.pdf"] = {
      content: "fake pdf content",
      mime_type: "application/pdf"
    }
    attachments["img.jpeg"] = File.read(File.join(__dir__, "..", "fixtures", "img.jpeg"))
    attachments["url_file.pdf"] = "https://sample-files.com/downloads/documents/pdf/basic-text.pdf"
    attachments["url_file2.pdf"] = { file: "https://sample-files.com/downloads/documents/pdf/basic-text.pdf",
                                     description: "Sample URL File2" }

    mail(to: to, subject: subject) do |format|
      format.text { render plain: "txt" }
    end
  end

  def with_multiple_recipients_text(to_list, subject)
    headers["unsubscribe_group_id"] = "group_123"

    mail(to: to_list, subject: subject) do |format|
      format.text { render plain: "bulk text" }
    end
  end

  def with_multiple_recipients_template(to_list, _subject)
    headers["unsubscribe_group_id"] = "group_123"
    headers["template_id"] = "tmpl_123"

    mail(to: to_list, body: "")
  end

  def with_display_name(to, subject)
    mail(to: to, subject: subject, from: "Sender Name <sender@example.com>") do |format|
      format.text { render plain: "text" }
    end
  end

  def with_reply_to(to, subject)
    mail(to: to, subject: subject, reply_to: "reply@example.com") do |format|
      format.text { render plain: "text" }
    end
  end

  def with_template_ids(to)
    headers["template_id"] = "tmpl_123"

    mail(to: to, body: "")
  end

  def with_unsubscribe_group(to)
    headers["unsubscribe_group_id"] = "group_123"

    mail(to: to, subject: "Unsubscribe Test") do |format|
      format.text { render plain: "text" }
    end
  end
end

class TestMailerIntegration < Minitest::Test
  def setup
    AutosendRb.configure do |config|
      config.api_key = "test_api_key"
    end
  end

  def test_html_text_msg
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "sender@example.com", payload.from.email
      assert_equal "recipient@example.com", payload.to.email
      assert_equal "Test Subject", payload.subject
      assert_equal "<p>HTML!</p>", payload.body.html
      assert_equal "text", payload.body.text
    end.returns({ "id" => "123" })

    IntegrationTestMailer.html_text_msg("recipient@example.com", "Test Subject").deliver_now
  end

  def test_text_only_msg
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "text", payload.body.text
      assert_nil payload.body.html
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.text_only("recipient@example.com", "Test Subject").deliver_now
  end

  def test_html_only_msg
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "<p>HTML!</p>", payload.body.html
      assert_nil payload.body.text
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.html_only("recipient@example.com", "Test Subject").deliver_now
  end

  def test_with_attachment
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal 4, payload.attachments.size
      [
        {
          fileName: "invoice.pdf",
          content: Base64.strict_encode64("fake pdf content"),
          contentType: "application/pdf"
        },
        {
          fileName: "img.jpeg",
          content: Base64.strict_encode64(File.read(File.join(__dir__, "..", "fixtures", "img.jpeg")))
        },
        {
          fileName: "url_file.pdf",
          fileUrl: "https://sample-files.com/downloads/documents/pdf/basic-text.pdf"
        },
        {
          fileName: "url_file2.pdf",
          fileUrl: "https://sample-files.com/downloads/documents/pdf/basic-text.pdf",
          description: "Sample URL File2"
        }
      ].each_with_index do |expected_att, index|
        att = payload.attachments[index].to_h
        assert_equal expected_att[:fileName], att[:fileName]
        assert_equal expected_att[:content], att[:content] if expected_att.key?(:content)
        assert_equal expected_att[:fileUrl], att[:fileUrl] if expected_att.key?(:fileUrl)
        assert_equal expected_att[:description], att[:description] if expected_att.key?(:description)
        assert_equal expected_att[:contentType], att[:contentType] if expected_att.key?(:contentType)
      end
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.with_attachment("recipient@example.com", "Test Subject").deliver_now
  end

  def test_multiple_recipients_uses_bulk_with_text
    recipients = ["a@example.com", "b@example.com"]

    AutosendRb::Clients::Mail.expects(:bulk).with do |payload|
      assert_equal 2, payload.recipients.size
      assert_equal "a@example.com", payload.recipients[0].email
      assert_equal "b@example.com", payload.recipients[1].email
      assert_equal "bulk text", payload.body.text
      assert_equal "group_123", payload.unsubscribe_group_id
      true
    end.returns({ "id" => "bulk_123" })

    IntegrationTestMailer.with_multiple_recipients_text(recipients, "Bulk Subject").deliver_now
  end

  def test_multiple_recipients_uses_bulk_with_template
    recipients = ["a@example.com", "b@example.com"]

    AutosendRb::Clients::Mail.expects(:bulk).with do |payload|
      assert_equal 2, payload.recipients.size
      assert_equal "a@example.com", payload.recipients[0].email
      assert_equal "b@example.com", payload.recipients[1].email
      assert_equal "tmpl_123", payload.body.template_id
      assert_equal "group_123", payload.unsubscribe_group_id

      assert_nil payload.subject
      assert_nil payload.body.text
      assert_nil payload.body.html
      true
    end.returns({ "id" => "bulk_123" })

    IntegrationTestMailer.with_multiple_recipients_template(recipients, "Bulk Subject").deliver_now
  end

  def test_with_display_name
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "sender@example.com", payload.from.email
      assert_equal "Sender Name", payload.from.name
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.with_display_name("recipient@example.com", "Test Subject").deliver_now
  end

  def test_with_reply_to
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "reply@example.com", payload.reply_to.email
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.with_reply_to("recipient@example.com", "Test Subject").deliver_now
  end

  def test_with_template_id
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "tmpl_123", payload.body.template_id
      assert_nil payload.subject # Subject is optional with template
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.with_template_ids("recipient@example.com").deliver_now
  end

  def test_with_unsubscribe_group
    AutosendRb::Clients::Mail.expects(:send).with do |payload|
      assert_equal "group_123", payload.unsubscribe_group_id
      true
    end.returns({ "id" => "123" })

    IntegrationTestMailer.with_unsubscribe_group("recipient@example.com").deliver_now
  end

  def test_api_error_propagation
    AutosendRb::Clients::Mail.expects(:send).raises(AutosendRb::Error.new("API Error"))

    assert_raises(AutosendRb::Error) do
      IntegrationTestMailer.html_text_msg("recipient@example.com", "Test Subject").deliver_now
    end
  end
end
