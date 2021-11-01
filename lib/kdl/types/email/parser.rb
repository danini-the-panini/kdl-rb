module KDL
  module Types
    class Email < Value
      class Parser
        def initialize(string)
          @string = string
          @tokenizer = Tokenizer.new(string)
        end

        def parse
          local = ''
          domain = nil
          context = :start

          loop do
            type, value = @tokenizer.next_token

            case type
            when :part
              case context
              when :start, :after_dot
                local += value
                context = :after_part
              else
                raise ArgumentError, "invalid email #{@string} (unexpected part #{value} at #{context})"
              end
            when :dot
              case context
              when :after_part
                local += value
                context = :after_dot
              else
                raise ArgumentError, "invalid email #{@string} (unexpected dot at #{context})"
              end
            when :at
              case context
              when :after_part
                context = :after_at
              end
            when :domain
              case context
              when :after_at
                raise ArgumentError, "invalid hostname #{value}" unless Hostname.valid_hostname?(value)
                domain = value
                context = :after_domain
              else
                raise ArgumentError, "invalid email #{@string} (unexpected domain at #{context})"
              end
            when :end
              case context
              when :after_domain
                if local.length > 64
                  raise ArgumentError, "invalid email #{@string} (local part length #{local.length} exceeds maximaum of 64)"
                end

                return [local, domain]
              else
                raise ArgumentError, "invalid email #{@string} (unexpected end at #{context})"
              end
            end
          end
        end
      end

      class Tokenizer
        def initialize(string)
          @string = string
          @index = 0
          @after_at = false
        end

        def next_token
          if @after_at
            if @index < @string.length
              domain_start = @index
              @index = @string.length
              return [:domain, @string[domain_start..-1]]
            else
              return [:end, nil]
            end
          end
          @context = nil
          @buffer = ''
          loop do
            c = @string[@index]
            return [:end, nil] if c.nil?

            case @context
            when nil
              case c
              when '.'
                @index += 1
                return [:dot, '.']
              when '@'
                @after_at = true
                @index += 1
                return [:at, '@']
              when '"'
                @context = :quote
                @index += 1
              when LOCAL_PART_CHARS
                @context = :part
                @buffer += c
                @index += 1
              else
                raise ArgumentError, "invalid email #{@string} (unexpected #{c})"
              end
            when :part
              case c
              when LOCAL_PART_CHARS
                @buffer += c
                @index += 1
              when '.', '@'
                return [:part, @buffer]
              else
                raise ArgumentError, "invalid email #{@string} (unexpected #{c})"
              end
            when :quote
              case c
              when '"'
                n = @string[@index + 1]
                raise ArgumentError, "invalid email #{@string} (unexpected #{c})" unless n == '.' || n == '@'

                @index += 1
                return [:part, @buffer]
              else
                @buffer += c
                @index += 1
              end
            end
          end
        end
      end
    end
  end
end
