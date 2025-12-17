# frozen_string_literal: true

module AutosendRb
  class Mail
    class << self
      def send(payload = nil, raise_error: false, &block)
        raise ArgumentError, "Cannot provide both a payload and a block" if payload && block_given?

        payload = AutosendRb::Requests::SendEmail.new(&block) if block_given?

        AutosendRb::Clients::Mail.send(payload, raise_error: raise_error)
      end

      def bulk(payload = nil, raise_error: false, &block)
        raise ArgumentError, "Cannot provide both a payload and a block" if payload && block_given?

        payload = AutosendRb::Requests::BulkEmail.new(&block) if block_given?

        AutosendRb::Clients::Mail.bulk(payload, raise_error: raise_error)
      end
    end
  end
end
