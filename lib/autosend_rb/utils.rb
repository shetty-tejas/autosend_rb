# frozen_string_literal: true

module AutosendRb
  module Utils
    class << self
      def valid_url?(str)
        uri = URI.parse(str)
        %w[http https].include?(uri.scheme)
      rescue URI::InvalidURIError
        false
      end

      def valid_path?(str)
        str.length < 1024 && str.match?(%r{\A[/\w\-. ]+\z})
      rescue StandardError
        false
      end
    end
  end
end
