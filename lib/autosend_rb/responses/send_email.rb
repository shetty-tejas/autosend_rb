# frozen_string_literal: true

module AutosendRb
  module Responses
    class SendEmail
      attr_reader :email_id

      def initialize(data)
        @email_id = data["emailId"]
      end
    end
  end
end
