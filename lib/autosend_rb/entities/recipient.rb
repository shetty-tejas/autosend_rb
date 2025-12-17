# frozen_string_literal: true

module AutosendRb
  module Entities
    class Recipient
      attr_reader :email, :name

      def initialize(email:, name: nil)
        raise TypeError, "email should be of type String" unless email.is_a?(String)
        raise TypeError, "name should be of type NilClass or String" unless name.nil? || name.is_a?(String)

        raise ArgumentError, "email can't be blank" if email.empty?
        raise ArgumentError, "name can't be blank" if name&.empty?

        @email = email
        @name = name
      end

      def to_h
        {
          email: email,
          name: name
        }
      end

      class << self
        def coerce(value)
          return value if value.is_a?(self)

          if value.is_a?(Hash)
            value = value.transform_keys(&:to_sym)
            return new(email: value[:email], name: value[:name])
          end

          raise ArgumentError, "Invalid recipient. Must be a Hash or #{name}"
        end
      end
    end
  end
end
