# frozen_string_literal: true

module AutosendRb
  module Entities
    class Body
      attr_accessor :html, :text, :template_id

      def initialize(html: nil, text: nil, template_id: nil)
        @html = html
        @text = text
        @template_id = template_id
      end

      def to_h
        {
          html: html,
          text: text,
          templateId: template_id
        }.compact
      end

      def validate!
        if template_id && (html || text)
          raise ArgumentError, "cannot provide html/text when template_id is present"
        end

        unless template_id
          raise ArgumentError, "html or text is required when not using a template" if (html.nil? || html.empty?) && (text.nil? || text.empty?)
        end
      end

      class << self
        def coerce(value)
          return value if value.is_a?(self)

          if value.is_a?(Hash)
            value = value.transform_keys(&:to_sym)
            return new(html: value[:html], text: value[:text], template_id: value[:template_id])
          end

          raise ArgumentError, "Invalid body. Must be a Hash or #{name}"
        end
      end
    end
  end
end
