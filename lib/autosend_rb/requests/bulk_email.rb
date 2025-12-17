# frozen_string_literal: true

module AutosendRb
  module Requests
    # Request object for sending bulk emails.
    class BulkEmail < Base
      # @return [String] The email subject.
      attr_accessor :subject
      # @return [Array<AutosendRb::Entities::Recipient>] The list of recipients.
      attr_reader :recipients
      # @return [AutosendRb::Entities::Recipient] The sender.
      attr_reader :from
      # @return [AutosendRb::Entities::Recipient] The reply-to address.
      attr_reader :reply_to
      # @return [Array<AutosendRb::Entities::Attachment>] The list of attachments.
      attr_reader :attachments
      # @return [String] The unsubscribe group ID.
      attr_reader :unsubscribe_group_id
      # @return [AutosendRb::Entities::Body] The email body.
      attr_reader :body

      # Initializes a new BulkEmail request.
      #
      # @param kwargs [Hash] Initial attributes.
      # @yield [self] Block to configure the request.
      def initialize(**kwargs)
        super
        @recipients = []
        @attachments = []

        yield self if block_given?
      end

      # Sets the recipients.
      #
      # @param values [Array<Hash, String, AutosendRb::Entities::Recipient>] The recipients.
      # @raise [ArgumentError] if values is not an array.
      def recipients=(values)
        raise ArgumentError, "recipients must be an array" unless values.is_a?(Array)

        @recipients = values.map { |v| Entities::Recipient.coerce(v) }
      end

      # Adds a recipient.
      #
      # @param value [Hash, String, AutosendRb::Entities::Recipient] The recipient.
      def add_recipient(value)
        @recipients << Entities::Recipient.coerce(value)
      end

      # Sets the sender.
      #
      # @param value [Hash, String, AutosendRb::Entities::Recipient] The sender.
      def from=(value)
        @from = Entities::Recipient.coerce(value)
      end

      # Sets the reply-to address.
      #
      # @param value [Hash, String, AutosendRb::Entities::Recipient] The reply-to address.
      def reply_to=(value)
        @reply_to = Entities::Recipient.coerce(value)
      end

      # Sets the email body.
      #
      # @param value [Hash, AutosendRb::Entities::Body] The email body.
      def body=(value)
        @body = Entities::Body.coerce(value)
      end

      # Sets the attachments.
      #
      # @param values [Array<Hash, String, File, AutosendRb::Entities::Attachment>] The attachments.
      # @raise [ArgumentError] if values is not an array.
      def attachments=(values)
        raise ArgumentError, "attachments must be an array" unless values.is_a?(Array)

        @attachments = values.map { |v| Entities::Attachment.coerce(v) }
      end

      # Adds an attachment.
      #
      # @param value [Hash, String, File, AutosendRb::Entities::Attachment] The attachment.
      def add_attachment(value)
        @attachments << Entities::Attachment.coerce(value)
      end

      # Sets the unsubscribe group ID.
      #
      # @param value [String] The unsubscribe group ID.
      # @raise [ArgumentError] if value is not a string.
      def unsubscribe_group_id=(value)
        raise ArgumentError, "unsubscribe_group_id should be of type String" unless value.is_a?(String)

        @unsubscribe_group_id = value
      end

      # Converts the request to a Hash.
      #
      # @return [Hash] The request payload.
      def to_h
        {
          recipients: recipients.map(&:to_h),
          from: from&.to_h,
          replyTo: reply_to&.to_h,
          subject: subject,
          unsubscribeGroupId: unsubscribe_group_id,
          attachments: attachments.map(&:to_h),
          **body.to_h
        }.compact
      end

      # Validates the request.
      #
      # @raise [ArgumentError] if the request is invalid.
      def validate!
        raise ArgumentError, "recipients and from details are required" if recipients.empty? || from.nil?
        raise ArgumentError, "maximum 100 recipients allowed" if recipients.size > 100

        validate_body!
        validate_attachments!
      end

      private

      def validate_body!
        raise ArgumentError, "body is required" unless body

        body.validate!

        return unless body.template_id.nil? && (subject.nil? || subject.empty?)

        raise ArgumentError, "subject is required when not using a template"
      end

      def validate_attachments!
        return if attachments.empty?

        raise ArgumentError, "maximum 20 attachments allowed" if attachments.size > 20

        total_size = attachments.sum do |attachment|
          data = attachment.to_h
          data[:content] ? data[:content].bytesize : 0
        end

        # 40MB in bytes = 40 * 1024 * 1024 = 41,943,040
        raise ArgumentError, "total attachment size exceeds 40MB" if total_size > 41_943_040
      end
    end
  end
end
