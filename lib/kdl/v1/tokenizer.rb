module KDL
  module V1
    class Tokenizer < KDL::Tokenizer
      NON_IDENTIFIER_CHARS = Regexp.escape "#{SYMBOLS.keys.join}()/\\<>[]\",#{WHITESPACE.join}#{OTHER_NON_IDENTIFIER_CHARS.join}"
      IDENTIFIER_CHARS = /[^#{NON_IDENTIFIER_CHARS}]/
      INITIAL_IDENTIFIER_CHARS = /[^#{NON_IDENTIFIER_CHARS}0-9]/

      def next_token
        @context = nil
        @previous_context = nil
        @line_at_start = @line
        @column_at_start = @column
        loop do
          c = self[@index]
          case @context
          when nil
            case c
            when '"'
              self.context = :string
              @buffer = ''
              traverse(1)
            when 'r'
              if @str[@index + 1] == '"'
                self.context = :rawstring
                traverse(2)
                @rawstring_hashes = 0
                @buffer = ''
                next
              elsif @str[@index + 1] == '#'
                i = @index + 1
                @rawstring_hashes = 0
                while @str[i] == '#'
                  @rawstring_hashes += 1
                  i += 1
                end
                if @str[i] == '"'
                  self.context = :rawstring
                  @index = i + 1
                  @buffer = ''
                  next
                end
              end
              self.context = :ident
              @buffer = c
              traverse(1)
            when '-'
              n = self[@index + 1]
              if n =~ /[0-9]/
                n2 = self[@index + 2]
                if n == '0' && n2 =~ /[box]/
                  self.context = integer_context(n2)
                  traverse(3)
                else
                  self.context = :decimal
                  traverse(1)
                end
              else
                self.context = :ident
                traverse(1)
              end
              @buffer = c
            when /[0-9+]/
              n = self[@index + 1]
              if c == '0' && n =~ /[box]/
                traverse(2)
                @buffer = ''
                self.context = integer_context(n)
              else
                self.context = :decimal
                @buffer = c
                traverse(1)
              end
            when '\\'
              t = Tokenizer.new(@str, @index + 1)
              la = t.next_token
              if la[0] == :NEWLINE || la[0] == :EOF || (la[0] == :WS && (lan = t.next_token[0]) == :NEWLINE || lan == :EOF)
                traverse_to(t.index)
                @buffer = "#{c}#{la[1].value}"
                @buffer += "\n" if lan == :NEWLINE
                self.context = :whitespace
              else
                raise_error "Unexpected '\\' (#{la[0]})"
              end
            when *SYMBOLS.keys
              return token(SYMBOLS[c], c).tap { traverse(1) }
            when *NEWLINES, "\r"
              nl = expect_newline
              return token(:NEWLINE, nl).tap do
                traverse(nl.length)
              end
            when "/"
              if self[@index + 1] == '/'
                self.context = :single_line_comment
                traverse(2)
              elsif self[@index + 1] == '*'
                self.context = :multi_line_comment
                @comment_nesting = 1
                traverse(2)
              elsif self[@index + 1] == '-'
                return token(:SLASHDASH, '/-').tap { traverse(2) }
              else
                self.context = :ident
                @buffer = c
                traverse(1)
              end
            when *WHITESPACE
              self.context = :whitespace
              @buffer = c
              traverse(1)
            when nil
              return [false, token(:EOF, :EOF)[1]] if @done

              @done = true
              return token(:EOF, :EOF)
            when INITIAL_IDENTIFIER_CHARS
              self.context = :ident
              @buffer = c
              traverse(1)
            when '('
              @type_context = true
              return token(:LPAREN, c).tap { traverse(1) }
            when ')'
              @type_context = false
              return token(:RPAREN, c).tap { traverse(1) }
            else
              raise_error "Unexpected character #{c.inspect}"
            end
          when :ident
            case c
            when IDENTIFIER_CHARS
              traverse(1)
              @buffer += c
            else
              case @buffer
              when 'true'  then return token(:TRUE, true)
              when 'false' then return token(:FALSE, false)
              when 'null'  then return token(:NULL, nil)
              else return token(:IDENT, @buffer)
              end
            end
          when :string
            case c
            when '\\'
              c2 = self[@index + 1]
              if c2.match?(NEWLINES_PATTERN)
                i = 2
                while self[@index + i].match?(NEWLINES_PATTERN)
                  i+=1
                end
                traverse(i)
              else
                @buffer += c
                @buffer += c2
                traverse(2)
              end
            when '"'
              return token(:STRING, unescape(@buffer)).tap { traverse(1) }
            when nil
              raise_error "Unterminated string literal"
            else
              @buffer += c
              traverse(1)
            end
          when :rawstring
            raise_error "Unterminated rawstring literal" if c.nil?

            if c == '"'
              h = 0
              h += 1 while self[@index + 1 + h] == '#' && h < @rawstring_hashes
              if h == @rawstring_hashes
                return token(:RAWSTRING, @buffer).tap { traverse(1 + h) }
              end
            end

            @buffer += c
            traverse(1)
          when :decimal
            case c
            when /[0-9.\-+_eE]/
              traverse(1)
              @buffer += c
            else
              return parse_decimal(@buffer)
            end
          when :hexadecimal
            case c
            when /[0-9a-fA-F_]/
              traverse(1)
              @buffer += c
            else
              return parse_hexadecimal(@buffer)
            end
          when :octal
            case c
            when /[0-7_]/
              traverse(1)
              @buffer += c
            else
              return parse_octal(@buffer)
            end
          when :binary
            case c
            when /[01_]/
              traverse(1)
              @buffer += c
            else
              return parse_binary(@buffer)
            end
          when :single_line_comment
            if c.nil?
              @done = true
              return token(:EOF, :EOF)
            elsif c.match?(NEWLINES_PATTERN)
              self.context = nil
              @column_at_start = @column
              next
            else
              traverse(1)
            end
          when :multi_line_comment
            if c == '/' && self[@index + 1] == '*'
              @comment_nesting += 1
              traverse(2)
            elsif c == '*' && self[@index + 1] == '/'
              @comment_nesting -= 1
              traverse(2)
              if @comment_nesting == 0
                revert_context
              end
            else
              traverse(1)
            end
          when :whitespace
            if WHITESPACE.include?(c)
              traverse(1)
              @buffer += c
            elsif c == "/" && self[@index + 1] == '*'
              self.context = :multi_line_comment
              @comment_nesting = 1
              traverse(2)
            elsif c == "\\"
              t = Tokenizer.new(@str, @index + 1)
              la = t.next_token
              if la[0] == :NEWLINE || la[0] == :EOF || (la[0] == :WS && (lan = t.next_token[0]) == :NEWLINE || lan == :EOF)
                traverse_to(t.index)
                @buffer += "#{c}#{la[1].value}"
                @buffer += "\n" if lan == :NEWLINE
              else
                raise_error "Unexpected '\\' (#{la[0]})"
              end
            else
              return token(:WS, @buffer)
            end
          else
            # :nocov:
            raise_error "Unknown context `#{@context}'"
            # :nocov:
          end
        end
      end

      private

      def allowed_in_type?(val)
        %i[ident string rawstring].include?(val)
      end

      def allowed_after_type?(val)
        !%i[single_line_comment multi_line_comment].include?(val)
      end

      def unescape(string)
        string.gsub(/\\[^u]/) do |m|
          case m
          when '\n' then "\n"
          when '\r' then "\r"
          when '\t' then "\t"
          when '\\\\' then "\\"
          when '\"' then "\""
          when '\b' then "\b"
          when '\f' then "\f"
          when '\/' then "/"
          else raise_error "Unexpected escape #{m.inspect}"
          end
        end.gsub(/\\u\{[0-9a-fA-F]{0,6}\}/) do |m|
          i = Integer(m[3..-2], 16)
          if i < 0 || i > 0x10FFFF
            raise_error "Invalid code point #{u}"
          end
          i.chr(Encoding::UTF_8)
        end
      end
    end
  end
end
