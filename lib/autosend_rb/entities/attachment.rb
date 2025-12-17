# frozen_string_literal: true

require "base64"
require "securerandom"
require "uri"

module AutosendRb
  module Entities
    # Represents an email attachment.
    class Attachment
      # @return [File, Tempfile, String] The file object or path/URL to the file.
      attr_reader :file

      # @return [String, nil] A description of the attachment.
      attr_reader :description

      # Initializes a new Attachment.
      #
      # @param file [File, Tempfile, String] The file object, local path, or URL.
      # @param description [String, nil] A description of the attachment.
      # @raise [TypeError] If file is not a File, Tempfile, or String, or if description is not a String.
      # @raise [ArgumentError] If file is an empty string.
      def initialize(file:, description: nil)
        unless file.is_a?(File) || file.is_a?(Tempfile) || file.is_a?(String)
          raise TypeError,
                "file should be of type File or String"
        end
        raise ArgumentError, "file should not be empty" if file.is_a?(String) && file.empty?
        raise TypeError, "description should be of type String" unless description.nil? || description.is_a?(String)

        @file = file
        @description = description
      end

      # Converts the attachment to a hash for API transmission.
      #
      # @return [Hash] The hash representation of the attachment.
      # @raise [ArgumentError] If the file path provided does not exist or cannot be read.
      def to_h
        if file.is_a?(File)
          return {
            filename: File.basename(file.path),
            content: Base64.encode64(file.read),
            description: description
          }
        end

        begin
          uri = URI.parse(file)
        rescue URI::InvalidURIError
          uri = nil
        end

        if uri && %w[http https].include?(uri.scheme)
          return {
            filename: File.basename(uri.path),
            fileUrl: file,
            description: description
          }
        end

        path = uri && uri.scheme == "file" ? uri.path : file

        raise ArgumentError, "file does not exist at path: #{path}" unless File.exist?(path)

        result = {}

        begin
          f = File.open(path)

          result = {
            filename: File.basename(f.path),
            content: Base64.encode64(f.read),
            description: description
          }
        rescue SystemCallError => e
          raise ArgumentError, "could not read file at #{path}: #{e.message}"
        ensure
          f&.close
        end

        result
      end

      class << self
        # Coerces a value into an Attachment object.
        #
        # @param value [Hash, File, String, Attachment] The value to coerce.
        # @return [Attachment] The coerced Attachment object.
        # @raise [ArgumentError] If the value cannot be coerced.
        def coerce(value)
          return value if value.is_a?(self)
          return new(file: value) if value.is_a?(File) || value.is_a?(String)

          if value.is_a?(Hash)
            value = value.transform_keys(&:to_sym)
            return new(file: value[:file], description: value[:description])
          end

          raise ArgumentError, "Invalid attachment. Must be a File, path String, Hash, or #{name}"
        end
      end
    end
  end
end
