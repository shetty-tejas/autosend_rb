# frozen_string_literal: true

module AutosendRb
  class Mail
    class << self
      def send(payload = nil, raise_error: false, &block)
        if payload && block_given?
          raise ArgumentError, "Cannot provide both a payload and a block"
        end

        if block_given?
          payload = AutosendRb::Requests::SendEmail.new(&block)
        end

        AutosendRb::Clients::Mail.send(payload, raise_error: raise_error)
      end
    end
  end
end
