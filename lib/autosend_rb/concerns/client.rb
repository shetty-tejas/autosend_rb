# frozen_string_literal: true

require "json"
require "net/http"

module AutosendRb
  module Concerns
    # Shared client functionality for making HTTP requests.
    # @api private
    module Client
      private

      def default_headers
        {
          "Content-Type": "application/json",
          "Authorization": "Bearer #{AutosendRb.config.api_key}"
        }
      end

      def post(path:, body: {}, headers: {})
        raise ArgumentError, "path should be a string" unless path.is_a?(String)

        uri = URI::HTTPS.build(host: AutosendRb.config.api_host, path: path)

        request = Net::HTTP::Post.new(uri).tap do |r|
          r.body = JSON.generate(body)

          default_headers.merge(headers).each do |k, v|
            r[k] = v
          end
        end

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: AutosendRb.config.http_timeout,
                                                read_timeout: AutosendRb.config.http_timeout) do |http|
          http.request(request)
        end
      end
    end
  end
end
