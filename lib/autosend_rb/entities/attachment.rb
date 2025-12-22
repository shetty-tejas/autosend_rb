# frozen_string_literal: true

require "base64"

module AutosendRb
  module Entities
    # Represents an email attachment.
    class Attachment
      # @return [File, Tempfile, String, Hash] The file object, path/URL, or hash with content.
      attr_reader :file

      # @return [String, nil] A description of the attachment.
      attr_reader :description

      # Initializes a new Attachment.
      #
      # @param file [File, Tempfile, String, Hash] The file object, local path, URL, or hash with content.
      # @param description [String, nil] A description of the attachment.
      # @raise [TypeError] If file is not a supported type or description is not a String.
      # @raise [ArgumentError] If file is invalid.
      def initialize(file:, description: nil)
        raise TypeError, "description should be of type String" unless description.nil? || description.is_a?(String)

        @description = description
        @strategy, @file = strategizer(file)
      end

      # Converts the attachment to a hash for API transmission.
      #
      # @return [Hash] The hash representation of the attachment.
      # @raise [ArgumentError] If the file path provided does not exist or cannot be read.
      def to_h
        base = case strategy
               when :raw then build_from_raw
               when :file_obj then build_from_file_obj
               when :url then build_from_url
               when :path then build_from_path
               end

        base.merge({ description: description }).compact
      end

      class << self
        # Coerces a value into an Attachment object.
        #
        # @param value [Hash, File, String, Attachment] The value to coerce.
        # @return [Attachment] The coerced Attachment object.
        # @raise [ArgumentError] If the value cannot be coerced.
        def coerce(value)
          case value
          when self then value
          when File, Tempfile, String then new(file: value)
          when Hash then coerce_hash(value)
          else
            raise ArgumentError, "Invalid attachment. Must be a File, path String, Hash, or #{name}"
          end
        end

        private

        def coerce_hash(hash)
          hash = hash.transform_keys(&:to_sym)

          if hash[:content] && hash[:filename]
            new(file: { content: hash[:content], filename: hash[:filename], content_type: hash[:content_type] },
                description: hash[:description])
          elsif hash[:file] && hash[:filename]
            new(file: { file: hash[:file], filename: hash[:filename] }, description: hash[:description])
          else
            new(file: hash[:file], description: hash[:description])
          end
        end
      end

      private

      attr_reader :strategy

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity -- would fix it if it becomes more complex.
      def strategizer(file)
        case file
        when File, Tempfile
          [:file_obj, file]
        when String
          raise ArgumentError, "file should not be empty" if file.empty?

          if AutosendRb::Utils.valid_url?(file)
            [:url, file]
          elsif AutosendRb::Utils.valid_path?(file)
            [:path, file]
          else
            raise ArgumentError, "file string is neither a valid URL nor a valid file path"
          end
        when Hash
          file = file.transform_keys(&:to_sym)

          raise ArgumentError, "file hash must contain :content or :file" unless file[:content] || file[:file]

          if file[:file]
            raise ArgumentError, "Nested file must be a String (URL or Path)" unless file[:file].is_a?(String)

            type, = strategizer(file[:file])
            return [type, file]
          end

          unless file[:content].is_a?(String) && !file[:content].empty?
            raise ArgumentError,
                  ":content must be of type String and not empty"
          end
          unless file[:filename].is_a?(String) && !file[:filename].empty?
            raise ArgumentError,
                  ":filename must be of type String and not empty"
          end

          [:raw, file]
        else
          raise TypeError, "file should be of type File, String, or Hash"
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def build_from_raw
        {
          fileName: file[:filename],
          content: Base64.strict_encode64(file[:content]),
          contentType: file[:content_type]
        }
      end

      def build_from_file_obj
        file.rewind
        {
          fileName: File.basename(file.path),
          content: Base64.strict_encode64(file.read)
        }.tap { |_| file.rewind }
      end

      def build_from_url
        if file.is_a?(Hash)
          url = file[:file]
          filename = file[:filename]
        else
          url = file
          filename = nil
        end

        {
          fileName: filename || File.basename(URI.parse(url).path),
          fileUrl: url
        }
      end

      def build_from_path
        if file.is_a?(Hash)
          path = file[:file]
          filename = file[:filename]
        else
          path = file
          filename = nil
        end

        raise ArgumentError, "file does not exist at path: #{path}" unless File.exist?(path)

        content = File.read(path)
        {
          fileName: filename || File.basename(path),
          content: Base64.strict_encode64(content)
        }
      rescue SystemCallError => e
        raise ArgumentError, "could not read file at #{path}: #{e.message}"
      end
    end
  end
end
