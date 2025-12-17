# frozen_string_literal: true

module AutosendRb
  module Entities
    class Body
      attr_accessor :html, :text, :template_id, :dynamic_data

      def initialize(html: nil, text: nil, template_id: nil, dynamic_data: nil)
        @html = html
        @text = text
        @template_id = template_id
        @dynamic_data = dynamic_data
      end

      def to_h
        {
          html: html,
          text: text,
          templateId: template_id,
          dynamicData: dynamic_data
        }.compact
      end

      def validate!
        raise ArgumentError, "cannot provide html/text when template_id is present" if template_id && (html || text)

        return if template_id

        return unless (html.nil? || html.empty?) && (text.nil? || text.empty?)

        raise ArgumentError,
              "html or text is required when not using a template"
      end

      class << self
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
