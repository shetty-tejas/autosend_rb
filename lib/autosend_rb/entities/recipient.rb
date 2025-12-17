# frozen_string_literal: true

module AutosendRb
  module Entities
    # Represents an email recipient.
    class Recipient
      # @return [String] The email address of the recipient.
      attr_reader :email

      # @return [String, nil] The name of the recipient.
      attr_reader :name

      # @return [Hash, nil] Dynamic data for template substitution.
      attr_reader :dynamic_data

      # Initializes a new Recipient.
      #
      # @param email [String] The email address.
      # @param name [String, nil] The name of the recipient.
      # @param dynamic_data [Hash, nil] Dynamic data for template substitution.
      # @raise [TypeError] If arguments are not of the expected type.
      # @raise [ArgumentError] If email is blank or name is blank (but not nil).
      def initialize(email:, name: nil, dynamic_data: nil)
        raise TypeError, "email should be of type String" unless email.is_a?(String)
        raise TypeError, "name should be of type NilClass or String" unless name.nil? || name.is_a?(String)

        unless dynamic_data.nil? || dynamic_data.is_a?(Hash)
          raise TypeError,
                "dynamic_data should be of type NilClass or Hash"
        end

        raise ArgumentError, "email can't be blank" if email.empty?
        raise ArgumentError, "name can't be blank" if name&.empty?

        @email = email
        @name = name
        @dynamic_data = dynamic_data
      end

      # Converts the recipient to a hash for API transmission.
      #
      # @return [Hash] The hash representation of the recipient.
      def to_h
        {
          email: email,
          name: name,
          dynamicData: dynamic_data
        }.compact
      end

      class << self
        # Coerces a value into a Recipient object.
        #
        # @param value [Hash, Recipient] The value to coerce.
        # @return [Recipient] The coerced Recipient object.
        # @raise [ArgumentError] If the value cannot be coerced.
        def coerce(value)
          return value if value.is_a?(self)

          if value.is_a?(Hash)
            value = value.transform_keys(&:to_sym)
            return new(email: value[:email], name: value[:name], dynamic_data: value[:dynamic_data])
          end

          raise ArgumentError, "Invalid recipient. Must be a Hash or #{name}"
        end
      end
    end
  end
end
