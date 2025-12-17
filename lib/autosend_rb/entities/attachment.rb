# frozen_string_literal: true

require "base64"
require "securerandom"
require "uri"

module AutosendRb
  module Entities
    class Attachment
      attr_reader :file, :description

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
        def coerce(value)
          return value if value.is_a?(self)

          # If it's a File or String (path), wrap it
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
