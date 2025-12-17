# frozen_string_literal: true

module AutosendRb
  module Requests
    # Base class for all request objects.
    class Base
      class << self
        # Builds a new request object.
        #
        # @param kwargs [Hash] Initial attributes.
        # @yield [request] Block to configure the request.
        # @return [AutosendRb::Requests::Base] The new request object.
        def build(**kwargs, &block)
          new(**kwargs).tap(&block)
        end
      end

      # Initializes a new request object.
      #
      # @param kwargs [Hash] Initial attributes.
      def initialize(**kwargs)
        kwargs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      # Converts the request object to a Hash for the API payload.
      #
      # @raise [NotImplementedError] if the subclass does not implement this method.
      def to_h
        raise NotImplementedError, "#{self.class} must implement #to_h"
      end

      def validate!
        true
      end
    end
  end
end
