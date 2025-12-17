# frozen_string_literal: true

module AutosendRb
  module Requests
    class SendEmail < Base
      attr_accessor :subject
      attr_reader :to, :from, :reply_to, :attachments, :unsubscribe_group_id, :body

      def initialize(**kwargs)
        super
        @attachments = []

        yield self if block_given?
      end

      def to=(value)
        @to = Entities::Recipient.coerce(value)
      end

      def from=(value)
        @from = Entities::Recipient.coerce(value)
      end

      def reply_to=(value)
        @reply_to = Entities::Recipient.coerce(value)
      end

      def body=(value)
        @body = Entities::Body.coerce(value)
      end

      def attachments=(values)
        raise ArgumentError, "attachments must be an array" unless values.is_a?(Array)

        @attachments = values.map { |v| Entities::Attachment.coerce(v) }
      end

      def add_attachment(value)
          @attachments << Entities::Attachment.coerce(value)
      end

      def unsubscribe_group_id=(value)
        raise ArgumentError, "unsubscribe_group_id should be of type String" unless value.is_a?(String)

        @unsubscribe_group_id = value
      end

      def to_h
        {
          to: to&.to_h,
          from: from&.to_h,
          replyTo: reply_to&.to_h,
          subject: subject,
          unsubscribeGroupId: unsubscribe_group_id,
          attachments: attachments.map(&:to_h),
          **body.to_h
        }.compact
      end

      def validate!
        raise ArgumentError, "to and from details are required" if to.nil? || from.nil?

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
