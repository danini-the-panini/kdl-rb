module KDL
  module Types
    class URLTemplate < Value
      UNRESERVED = /[a-zA-Z0-9\-._~]/
      RESERVED = /[:\/?#\[\]@!$&'()*+,;=]/

      def self.call(value, type = 'url-template')
        return nil unless value.is_a? ::KDL::Value::String

        parts = Parser.parse(value.value)
        new(parts, type: type)
      end

      def expand(variables)
        result = value.map { |v| v.expand(variables) }.join
        parser = IRLReference::Parser.new(result)
        uri, * = parser.parse
        URI(uri)
      end

      class Parser
        def self.parse(string)
          new(string).parse
        end

        def initialize(string)
          @string = string
          @index = 0
        end

        def parse
          result = []
          until (token = next_token).nil?
            result << token
          end
          result
        end

        def next_token
          buffer = ''
          context = nil
          expansion_type = nil
          loop do
            c = @string[@index]
            #puts "#{@index}/#{context} => #{c}"
            case context
            when nil
              case c
              when '{'
                context = :expansion
                buffer = ''
                n = @string[@index+1]
                expansion_type = case n
                                 when '+' then ReservedExpansion
                                 when '#' then FragmentExpansion
                                 when '.' then LabelExpansion
                                 when '/' then PathExpantion
                                 when ';' then ParameterExpansion
                                 when '?' then QueryExpansion
                                 when '&' then QueryContinuation
                                 else StringExpansion
                                 end
                @index += (expansion_type == StringExpansion ? 1 : 2)
              when nil then return nil
              else
                buffer = c
                @index += 1
                context = :literal
              end
            when :literal
              case c
              when '{', nil then return StringLiteral.new(buffer)
              else
                buffer << c
                @index += 1
              end
            when :expansion
              case c
              when '}'
                @index += 1
                return parse_expansion(buffer, expansion_type)
              when nil
                raise ArgumentError, 'unterminated expansion'
              else
                buffer << c
                @index += 1
              end
            end
          end
        end

        def parse_expansion(string, type)
          variables = string.split(',').map do |str|
            case str
            when /(.*)\*$/
              Variable.new(Regexp.last_match(1),
                           explode: true,
                           allow_reserved: type.allow_reserved?,
                           with_name: type.with_name?,
                           keep_empties: type.keep_empties?)
            when /(.*):(\d+)/
              Variable.new(Regexp.last_match(1),
                           limit: Regexp.last_match(2).to_i,
                           allow_reserved: type.allow_reserved?,
                           with_name: type.with_name?,
                           keep_empties: type.keep_empties?)
            else
              Variable.new(str,
                           allow_reserved: type.allow_reserved?,
                           with_name: type.with_name?,
                           keep_empties: type.keep_empties?)
            end
          end
          type.new(variables)
        end
      end

      class Variable
        attr_reader :name

        def initialize(name, limit: nil, explode: false, allow_reserved: false, with_name: false, keep_empties: false)
          @name = name.to_sym
          @limit = limit
          @explode = explode
          @allow_reserved = allow_reserved
          @with_name = with_name
          @keep_empties = keep_empties
        end

        def expand(value)
          if @explode
            case value
            when Array
              value.map { |v| prefix(encode(v)) }
            when Hash
              value.map { |k, v| prefix(encode(v), k) }
            else
              [prefix(encode(value))]
            end
          elsif @limit
            [prefix(limit(value))].compact
          else
            [prefix(flatten(value))].compact
          end
        end

        def limit(string)
          return nil unless string

          encode(string[0, @limit])
        end

        def flatten(value)
          case value
          when String
            encode(value)
          when Array, Hash
            result = value.to_a
                          .flatten
                          .compact
                          .map { |v| encode(v) }
            result.empty? ? nil : result.join(',')
          end
        end

        def encode(string)
          return nil unless string

          string.to_s
                .chars
                .map do |c|
                  if UNRESERVED.match?(c) || (@allow_reserved && RESERVED.match?(c))
                    c
                  else
                    IRLReference::Parser.percent_encode(c)
                  end
                end
                .join
                .force_encoding('utf-8')
        end

        def prefix(string, override = nil)
          return nil unless string

          key = override || @name

          if @with_name || override
            if string.empty? && !@keep_empties
              encode(key)
            else
              "#{encode(key)}=#{string}"
            end
          else
            string
          end
        end
      end

      class Part
        def expand_variables(values)
          @variables.reduce([]) do |list, variable|
            expanded = variable.expand(values[variable.name])
            expanded ? list + expanded : list
          end
        end

        def separator
          ','
        end

        def prefix
          ''
        end

        def self.allow_reserved?
          false
        end

        def self.with_name?
          false
        end

        def self.keep_empties?
          false
        end
      end

      class StringLiteral < Part
        def initialize(value)
          super()
          @value = value
        end

        def expand(*)
          @value
        end
      end

      class StringExpansion < Part
        def initialize(variables)
          super()
          @variables = variables
        end

        def expand(values)
          expanded = expand_variables(values)
          return '' if expanded.empty?

          prefix + expanded.join(separator)
        end
      end

      class ReservedExpansion < StringExpansion
        def self.allow_reserved?
          true
        end
      end

      class FragmentExpansion < StringExpansion
        def prefix
          '#'
        end

        def self.allow_reserved?
          true
        end
      end

      class LabelExpansion < StringExpansion
        def prefix
          '.'
        end

        def separator
          '.'
        end
      end

      class PathExpantion < StringExpansion
        def prefix
          '/'
        end

        def separator
          '/'
        end
      end

      class ParameterExpansion < StringExpansion
        def prefix
          ';'
        end

        def separator
          ';'
        end

        def self.with_name?
          true
        end
      end

      class QueryExpansion < StringExpansion
        def prefix
          '?'
        end

        def separator
          '&'
        end

        def self.with_name?
          true
        end

        def self.keep_empties?
          true
        end
      end

      class QueryContinuation < QueryExpansion
        def prefix
          '&'
        end
      end
    end
    MAPPING['url-template'] = URLTemplate
  end
end
