# frozen_string_literal: true

module AutosendRb
  module Requests
    class Base
      class << self
        def build(**kwargs, &block)
          new(**kwargs).tap(&block)
        end
      end

      def initialize(**kwargs)
        kwargs.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end

      def to_h
        raise NotImplementedError, "#{self.class} must implement #to_h"
      end

      def validate!
        true
      end
    end
  end
end
