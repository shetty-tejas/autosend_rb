# frozen_string_literal: true

require "base64"
require "securerandom"
require "uri"

module AutosendRb
  module Entities
    class Attachment
      attr_reader :file

      def initialize(file:)
        raise TypeError, "file should be of type File or String" unless file.is_a?(File) || file.is_a?(String)
        raise ArgumentError, "file should not be empty" if file.is_a?(String) && file.empty?

        @file = file
      end

      def to_h
        if file.is_a?(File)
          return {
            filename: File.basename(file.path),
            content: Base64.encode64(file.read)
          }
        end

        begin
          uri = URI.parse(file)
        rescue URI::InvalidURIError
          uri = nil
        end

        if uri && %w[http https].include?(uri.scheme)
          {
            filename: File.basename(uri.path),
            fileUrl: file
          }
        else
          path = (uri && uri.scheme == "file") ? uri.path : file

          unless File.exist?(path)
            raise ArgumentError, "file does not exist at path: #{path}"
          end

          begin
            file_obj = File.open(path)
            {
              filename: File.basename(file_obj.path),
              content: Base64.encode64(file_obj.read)
            }
          rescue SystemCallError => e
            raise ArgumentError, "could not read file at #{path}: #{e.message}"
          ensure
            file_obj&.close
          end
        end
      end

      class << self
        def coerce(value)
          return value if value.is_a?(self)

          # If it's a File or String (path), wrap it
          return new(file: value) if value.is_a?(File) || value.is_a?(String)

          raise ArgumentError, "Invalid attachment. Must be a File, path String, or #{name}"
        end
      end
    end
  end
end
