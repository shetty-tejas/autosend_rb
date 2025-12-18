# frozen_string_literal: true

require "autosend_rb/mail"

module AutosendRb
  # Mailer class used by railtie
  class Mailer
    attr_accessor :settings

    def initialize(_)
      raise AutosendRb::ConfigurationError, "Make sure your API Key is set" unless AutosendRb.config.api_key
    end

    #
    # Overwritten deliver! method
    #
    # @param Mail mail
    #
    # @return Object autosend response
    #
    def deliver!(mail)
      # Trade-off: Autosend SendEmail supports single recipient only,
      # so if mail.to has multiple addresses, we use bulk send for now.
      if mail.to.size > 1
        deliver_bulk(mail)
      else
        deliver_single(mail)
      end
    end

    private

    def deliver_single(mail)
      AutosendRb::Mail.send(raise_error: true) do |req|
        # Trade-off: SendEmail request supports single recipient only for to, from, reply_to.
        req.from = get_from(mail).first
        req.to = get_to(mail).first
        req.reply_to = get_reply_to(mail).first

        req.subject = mail.subject
        req.body = get_body(mail)
        req.attachments = get_attachments(mail)
        req.unsubscribe_group_id = get_unsubscribe_group_id(mail)
      end
    end

    def deliver_bulk(mail)
      AutosendRb::Mail.bulk(raise_error: true) do |req|
        # Trade-off: SendEmail request supports single recipient only for from, reply_to.
        req.from = get_from(mail).first
        req.reply_to = get_reply_to(mail).first
        req.recipients = get_to(mail)

        req.subject = mail.subject
        req.body = get_body(mail)
        req.attachments = get_attachments(mail)
        req.unsubscribe_group_id = get_unsubscribe_group_id(mail)
      end
    end

    def get_from(mail)
      get_addresses(:from, mail)
    end

    def get_to(mail)
      get_addresses(:to, mail)
    end

    def get_reply_to(mail)
      get_addresses(:reply_to, mail)
    end

    def get_body(mail)
      return { template_id: mail[:template_id].value } if mail[:template_id]&.present?

      case mail.mime_type
      when "text/plain"
        { text: mail.body.decoded }
      when "text/html"
        { html: mail.body.decoded }
      when "multipart/alternative", "multipart/mixed", "multipart/related"
        {
          text: mail.text_part&.decoded,
          html: mail.html_part&.decoded
        }
      else
        # Fallback for simple emails that might not report mime_type as expected or are just text
        { text: mail.body.decoded }
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity -- would fix it if it becomes more complex.
    def get_attachments(mail)
      return [] if mail.attachments.empty?

      mail.attachments.map do |part|
        if part.body.blank? && part[:file]&.present?
          part.body = part[:file].value
          part["Content-Description"] = part[:description] if part[:description]&.present?
        end
        content = part.body.raw_source

        # Heuristic: If content is a valid URL or existing file path, treat it as a reference.
        # Otherwise, treat it as raw file content (default ActionMailer behavior).
        if AutosendRb::Utils.valid_url?(content) || (AutosendRb::Utils.valid_path?(content) && File.exist?(content))
          {
            filename: part.filename,
            file: content,
            description: part["Content-Description"]&.value
          }
        else
          {
            filename: part.filename,
            content: content,
            content_type: part.content_type,
            description: part["Content-Description"]&.value
          }
        end
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def get_addresses(type, mail)
      return [] if mail[type].nil?

      mail[type].addrs.map do |addr|
        { email: addr.address, name: addr.name }
      end
    end

    def get_unsubscribe_group_id(mail)
      mail[:unsubscribe_group_id].value if mail[:unsubscribe_group_id]&.present?
    end
  end
end
