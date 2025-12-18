# frozen_string_literal: true

module AutosendRb
  # Facade for sending emails.
  # This is the main entry point for sending emails.
  class Mail
    class << self
      # Sends a single email.
      #
      # @param payload [AutosendRb::Requests::SendEmail, Hash, nil] The request payload. Optional if a block is given.
      # @param raise_error [Boolean] Whether to raise an error if the API request fails. Defaults to false.
      # @yield [email] A block to build the email request.
      # @yieldparam email [AutosendRb::Requests::SendEmail] The email request builder.
      # @return [AutosendRb::Responses::SendEmail] The API response.
      # @raise [ArgumentError] if both payload and block are provided.
      #
      # @example Using a block
      #   AutosendRb::Mail.send do |email|
      #     email.to = "recipient@example.com"
      #     email.from = "sender@example.com"
      #     email.subject = "Hello"
      #     email.text = "World"
      #   end
      def send(payload = nil, raise_error: false, &block)
        raise ArgumentError, "Cannot provide both a payload and a block" if payload && block_given?

        payload = AutosendRb::Requests::SendEmail.build(&block) if block_given?

        AutosendRb::Clients::Mail.send(payload, raise_error: raise_error)
      end

      # Sends a bulk email to multiple recipients.
      #
      # @param payload [AutosendRb::Requests::BulkEmail, Hash, nil] The request payload. Optional if a block is given.
      # @param raise_error [Boolean] Whether to raise an error if the API request fails. Defaults to false.
      # @yield [email] A block to build the bulk email request.
      # @yieldparam email [AutosendRb::Requests::BulkEmail] The bulk email request builder.
      # @return [AutosendRb::Responses::BulkEmail] The API response.
      # @raise [ArgumentError] if both payload and block are provided.
      #
      # @example Using a block
      #   AutosendRb::Mail.bulk do |email|
      #     email.from = "sender@example.com"
      #     email.subject = "Newsletter"
      #     email.html = "<h1>Hello {{name}}</h1>"
      #     email.add_recipient(email: "alice@example.com", name: "Alice")
      #     email.add_recipient(email: "bob@example.com", name: "Bob")
      #   end
      def bulk(payload = nil, raise_error: false, &block)
        raise ArgumentError, "Cannot provide both a payload and a block" if payload && block_given?

        payload = AutosendRb::Requests::BulkEmail.build(&block) if block_given?

        AutosendRb::Clients::Mail.bulk(payload, raise_error: raise_error)
      end
    end
  end
end
