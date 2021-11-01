module KDL
  module Types
    class Email < Value
      class Parser
        def initialize(string, idn: false)
          @string = string
          @idn = idn
          @tokenizer = Tokenizer.new(string, idn: idn)
        end

        def parse
          local = ''
          ascii_domain = nil
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

                ascii_domain = value
                domain = @idn ? SimpleIDN.to_unicode(value) : value
                context = :after_domain
              else
                raise ArgumentError, "invalid email #{@string} (unexpected domain at #{context})"
              end
            when :end
              case context
              when :after_domain
                if local.size > 64
                  raise ArgumentError, "invalid email #{@string} (local part length #{local.size} exceeds maximaum of 64)"
                end

                return [local, domain, ascii_domain]
              else
                raise ArgumentError, "invalid email #{@string} (unexpected end at #{context})"
              end
            end
          end
        end
      end

      class Tokenizer
        LOCAL_PART_ASCII = /[a-zA-Z0-9!#\$%&'*+\-\/=?\^_`{|}~]/
        LOCAL_PART_IDN = /[^\x00-\x1f\s".@]/

        def initialize(string, idn: false)
          @string = string
          @idn = idn
          @index = 0
          @after_at = false
        end

        def next_token
          if @after_at
            if @index < @string.size
              domain_start = @index
              @index = @string.size
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
              when local_part_chars
                @context = :part
                @buffer += c
                @index += 1
              else
                raise ArgumentError, "invalid email #{@string} (unexpected #{c})"
              end
            when :part
              case c
              when local_part_chars
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

        def local_part_chars
          @idn ? LOCAL_PART_IDN : LOCAL_PART_ASCII
        end
      end
    end
  end
end
