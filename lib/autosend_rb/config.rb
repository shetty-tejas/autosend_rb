# frozen_string_literal: true

require "singleton"

module AutosendRb
  class Config
    include Singleton

    attr_accessor :api_host, :http_timeout
    attr_writer :api_key

    def initialize
      self.api_host = "api.autosend.com"
      self.http_timeout = 10
    end

    def api_key
      value = @api_key
      value = value.call if value.is_a?(Proc)

      raise ArgumentError, "api_key is missing" if value.nil? || value.empty?

      value
    end
  end
end
