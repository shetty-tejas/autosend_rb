# frozen_string_literal: true

module AutosendRb
  module Entities
    # Represents the body of an email, including HTML, text, or template information.
    class Body
      # @return [String, nil] The HTML content of the email.
      attr_accessor :html

      # @return [String, nil] The plain text content of the email.
      attr_accessor :text

      # @return [String, nil] The ID of the template to use.
      attr_accessor :template_id

      # @return [Hash, nil] Dynamic data for template substitution.
      attr_accessor :dynamic_data

      # Initializes a new Body.
      #
      # @param html [String, nil] The HTML content.
      # @param text [String, nil] The plain text content.
      # @param template_id [String, nil] The template ID.
      # @param dynamic_data [Hash, nil] Dynamic data for template substitution.
      def initialize(html: nil, text: nil, template_id: nil, dynamic_data: nil)
        @html = html
        @text = text
        @template_id = template_id
        @dynamic_data = dynamic_data
      end

      # Converts the body to a hash for API transmission.
      #
      # @return [Hash] The hash representation of the body.
      def to_h
        {
          html: html,
          text: text,
          templateId: template_id,
          dynamicData: dynamic_data
        }.compact
      end

      # Validates the body content.
      #
      # @raise [ArgumentError] If both template_id and html/text are present, or if neither are present.
      def validate!
        raise ArgumentError, "cannot provide html/text when template_id is present" if template_id && (html || text)

        return if template_id

        return unless (html.nil? || html.empty?) && (text.nil? || text.empty?)

        raise ArgumentError,
              "html or text is required when not using a template"
      end

      class << self
        # Coerces a value into a Body object.
        #
        # @param value [Hash, Body] The value to coerce.
        # @return [Body] The coerced Body object.
        # @raise [ArgumentError] If the value cannot be coerced.
        def coerce(value)
          return value if value.is_a?(self)

          if value.is_a?(Hash)
            value = value.transform_keys(&:to_sym)
            return new(
              html: value[:html],
              text: value[:text],
              template_id: value[:template_id],
              dynamic_data: value[:dynamic_data]
            )
          end

          raise ArgumentError, "Invalid body. Must be a Hash or #{name}"
        end
      end
    end
  end
end
