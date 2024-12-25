# frozen_string_literal: true

module KDL
  module Types
    class IRLReference < Value::Custom
      class Parser
        RGX = /^(?:(?:([a-z][a-z0-9+.\-]+)):\/\/([^@]+@)?([^\/?#]+)?)?(\/?[^?#]*)?(?:\?([^#]*))?(?:#(.*))?$/i.freeze
        PERCENT_RGX = /%[a-f0-9]{2}/i.freeze

        RESERVED_URL_CHARS = %w[! # $ & ' ( ) * + , / : ; = ? @ \[ \] %]
        UNRESERVED_URL_CHARS = %w[A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
                                  a b c d e f g h i j k l m n o p q r s t u v w x y z
                                  0 1 2 3 4 5 6 7 8 9 - _ . ~].freeze
        URL_CHARS = RESERVED_URL_CHARS + UNRESERVED_URL_CHARS

        def initialize(string)
          @string = string
        end

        def parse
          scheme, auth, domain, path, search, hash = *parse_url

          if @string.ascii_only?
            unicode_path = Parser.decode(path)
            unicode_search = Parser.decode(search)
            unicode_hash = Parser.decode(hash)
          else
            unicode_path = path
            path = Parser.encode(unicode_path)
            unicode_search = search
            search_params = unicode_search ? unicode_search.split('&').map { |x| x.split('=') } : nil
            search = search_params ? search_params.map { |k, v| "#{Parser.encode(k)}=#{Parser.encode(v)}" }.join('&') : nil
            unicode_hash = hash
            hash = Parser.encode(hash)
          end

          if domain
            validator = IDNHostname::Validator.new(domain)
            domain = validator.ascii
            unicode_domain = validator.unicode
          else
            unicode_domain = domain
          end

          unicode_value = Parser.build_uri_string(scheme, auth, unicode_domain, unicode_path, unicode_search, unicode_hash)
          ascii_value = Parser.build_uri_string(scheme, auth, domain, path, search, hash)

          [ascii_value,
           { unicode_value: unicode_value,
             unicode_domain: unicode_domain,
             unicode_path: unicode_path,
             unicode_search: unicode_search,
             unicode_hash: unicode_hash }]
        end

        def parse_url
          match = RGX.match(@string)
          raise ArgumentError, "invalid IRL `#{@string}'" if match.nil?

          _, *parts = *match
          raise ArgumentError, "invalid IRL `#{@string}'" unless parts.all? { |part| Parser.valid_url_part?(part) }

          parts
        end

        def self.valid_url_part?(string)
          return true unless string

          string.chars.all? do |char|
            !char.ascii_only? || URL_CHARS.include?(char)
          end
        end

        def self.encode(string)
          return string unless string

          string.chars
                .map { |c| c.ascii_only? ? c : percent_encode(c) }
                .join
                .force_encoding('utf-8')
        end

        def self.decode(string)
          return string unless string

          string.gsub(PERCENT_RGX) do |match|
            char = match[1, 2].to_i(16).chr
            if RESERVED_URL_CHARS.include?(char)
              match
            else
              char
            end
          end.force_encoding('utf-8')
        end

        def self.percent_encode(c)
          c.bytes.map { |b| "%#{b.to_s(16)}" }.join.upcase
        end

        def self.build_uri_string(scheme, auth, domain, path, search, hash)
          string = ''
          string += "#{scheme}://" if scheme
          string += auth if auth
          string += domain if domain
          string += path if path
          string += "?#{search}" if search
          string += "##{hash}" if hash
          string
        end
      end
    end

    class IRL < IRLReference
      class Parser < IRLReference::Parser
        def parse_url
          parts = super
          scheme, * = parts
          raise ArgumentError, "invalid IRL `#{@string}'" if scheme.nil? || scheme.empty?

          parts
        end
      end
    end
  end
end
