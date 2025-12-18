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

      def get(path:, headers: {})
        request(method: Net::HTTP::Get, path: path, headers: headers)
      end

      def post(path:, body: {}, headers: {})
        request(method: Net::HTTP::Post, path: path, body: body, headers: headers)
      end

      def put(path:, body: {}, headers: {})
        request(method: Net::HTTP::Put, path: path, body: body, headers: headers)
      end

      def delete(path:, headers: {})
        request(method: Net::HTTP::Delete, path: path, headers: headers)
      end

      def request(method:, path:, body: nil, headers: {})
        raise TypeError, "method should be a Net::HTTPRequest" unless method < Net::HTTPRequest
        raise ArgumentError, "path should be a string" unless path.is_a?(String)

        uri = URI::HTTPS.build(host: AutosendRb.config.api_host, path: path)

        req = method.new(uri).tap do |r|
          r.body = JSON.generate(body) if body

          default_headers.merge(headers).each do |k, v|
            r[k] = v
          end
        end

        Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, open_timeout: AutosendRb.config.http_timeout,
                                                read_timeout: AutosendRb.config.http_timeout) do |http|
          http.request(req)
        end
      end
    end
  end
end
