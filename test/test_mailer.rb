# frozen_string_literal: true

# # frozen_string_literal: true

# require "test_helper"
# require "mail"

# require "autosend_rb/mailer"

# class TestMailer < Minitest::Test
#   def setup
#     AutosendRb.configure { |c| c.api_key = "test_key" }
#     @mailer = AutosendRb::Mailer.new({})
#   end

#   def test_initialization_raises_without_api_key
#     AutosendRb.configure { |c| c.api_key = nil }
#     assert_raises(AutosendRb::ConfigurationError) do
#       AutosendRb::Mailer.new({})
#     end
#   end

#   def test_deliver_single_recipient
#     mail = Mail.new do
#       from    "sender@example.com"
#       to      "recipient@example.com"
#       subject "Test Subject"
#       body    "Test Body"
#     end

#     AutosendRb::Mail.expects(:send).with do |request, options|
#       assert_kind_of AutosendRb::Requests::SendEmail, request
#       assert_equal "sender@example.com", request.from.email
#       assert_equal "recipient@example.com", request.to.email
#       assert_equal "Test Subject", request.subject
#       assert_equal "Test Body", request.body.text
#       assert_equal true, options[:raise_error]
#     end

#     @mailer.deliver!(mail)
#   end

#   def test_deliver_multiple_recipients_uses_bulk
#     mail = Mail.new do
#       from    "sender@example.com"
#       to      ["a@example.com", "b@example.com"]
#       subject "Bulk Subject"
#       body    "Bulk Body"
#     end

#     AutosendRb::Mail.expects(:bulk).with do |request, options|
#       assert_kind_of AutosendRb::Requests::BulkEmail, request
#       assert_equal 2, request.recipients.size
#       assert_equal "a@example.com", request.recipients[0].email
#       assert_equal "b@example.com", request.recipients[1].email
#       assert_equal "sender@example.com", request.from.email
#       assert_equal "Bulk Subject", request.subject
#       assert_equal true, options[:raise_error]
#     end

#     @mailer.deliver!(mail)
#   end

#   def test_deliver_with_html_body
#     mail = Mail.new do
#       from    "sender@example.com"
#       to      "recipient@example.com"
#       subject "HTML Subject"
#       html_part do
#         content_type 'text/html; charset=UTF-8'
#         body '<h1>Hello</h1>'
#       end
#       text_part do
#         body 'Hello'
#       end
#     end

#     AutosendRb::Mail.expects(:send).with do |request, _|
#       assert_equal "<h1>Hello</h1>", request.body.html
#       assert_equal "Hello", request.body.text
#     end

#     @mailer.deliver!(mail)
#   end

#   def test_deliver_with_attachments
#     mail = Mail.new do
#       from    "sender@example.com"
#       to      "recipient@example.com"
#       subject "Attachment Subject"
#       body    "Body"
#       add_file filename: 'test.txt', content: 'hello world'
#     end

#     AutosendRb::Mail.expects(:send).with do |request, _|
#       assert_equal 1, request.attachments.size
#       attachment = request.attachments.first
#       assert_equal "test.txt", attachment.file[:filename]
#       assert_equal Base64.strict_encode64("hello world"), attachment.file[:content]
#     end

#     @mailer.deliver!(mail)
#   end

#   def test_deliver_with_reply_to
#     mail = Mail.new do
#       from     "sender@example.com"
#       to       "recipient@example.com"
#       reply_to "reply@example.com"
#     end

#     AutosendRb::Mail.expects(:send).with do |request, _|
#       assert_equal "reply@example.com", request.reply_to.email
#     end

#     @mailer.deliver!(mail)
#   end

#   def test_deliver_with_names
#     mail = Mail.new do
#       from    "Sender Name <sender@example.com>"
#       to      "Recipient Name <recipient@example.com>"
#     end

#     AutosendRb::Mail.expects(:send).with do |request, _|
#       assert_equal "sender@example.com", request.from.email
#       assert_equal "Sender Name", request.from.name
#       assert_equal "recipient@example.com", request.to.email
#       # Note: AutosendRb::Mailer currently extracts name for FROM but TO is just email in get_to logic
#       # Let's verify what we implemented.
#       # In mailer.rb: get_to uses get_addresses which extracts name.
#       # But deliver_single uses get_to(mail).first.
#       # So request.to should have name if get_addresses extracts it.
#       assert_equal "Recipient Name", request.to.name
#     end

#     @mailer.deliver!(mail)
#   end

#   def test_deliver_with_template_id
#     mail = Mail.new do
#       from "sender@example.com"
#       to   "recipient@example.com"
#     end
#     # Simulate setting template_id via mail[] hash access which Rails allows
#     mail[:template_id] = "tmpl_123"

#     AutosendRb::Mail.expects(:send).with do |request, _|
#       assert_equal "tmpl_123", request.body.template_id
#     end

#     @mailer.deliver!(mail)
#   end
# end
