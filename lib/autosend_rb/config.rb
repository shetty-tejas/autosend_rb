# frozen_string_literal: true

require "singleton"

module AutosendRb
  # Configuration class for the gem.
  # Use AutosendRb.configure to set these values.
  class Config
    include Singleton

    # @return [String] The API host URL. Defaults to "api.autosend.com".
    attr_accessor :api_host
    # @return [Integer] The HTTP timeout in seconds. Defaults to 10.
    attr_accessor :http_timeout
    # @return [String, Proc] The API key.
    attr_writer :api_key

    def initialize
      self.api_host = "api.autosend.com"
      self.http_timeout = 10
    end

    # Returns the API key.
    #
    # @return [String] The API key
    # @raise [ArgumentError] if api_key is missing or empty
    def api_key
      value = @api_key
      value = value.call if value.is_a?(Proc)

      raise ArgumentError, "api_key is missing" if value.nil? || value.empty?

      value
    end
  end
end
