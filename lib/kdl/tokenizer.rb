module KDL
  class Tokenizer
    class Error < StandardError; end

    SYMBOLS = {
      '{' => :LPAREN,
      '}' => :RPAREN,
      '=' => :EQUALS,
      ';' => :SEMICOLON
    }

    def initialize(str)
      @str = str
      @context = nil
      @rawstring_hashes = nil
      @index = 0
      @buffer = ""
      @done = false
      @previous_context = nil
    end

    def next_token
      @context = nil
      @previous_context = nil
      loop do
        c = @str[@index]
        case @context
        when nil
          case c
          when '"'
            self.context = :string
            @buffer = ''
            @index += 1
          when 'r'
            if @str[@index + 1] == '"'
              self.context = :rawstring
              @index += 2
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
                next
              end
            end
            self.context = :ident
            @buffer = c
            @index += 1
          when /[0-9\-+]/
            n = @str[@index + 1]
            if c == '0' && n.match?(/[box]/)
              @index += 2
              @buffer = ''
              self.context = case n
                         when 'b' then :binary
                         when 'o' then :octal
                         when 'x' then :hexadecimal
                         end
            else
              self.context = :decimal
              @index += 1
              @buffer = c
            end
          when *SYMBOLS.keys
            @index += 1
            return [SYMBOLS[c], c]
          when "\n"
            @index += 1
            return [:NEWLINE, c]
          when "\r"
            n = @str[@index + 1]
            if n == "\n"
              @index += 2
              return [:NEWLINE, "#{c}#{n}"]
            end
          when "/"
            if @str[@index + 1] == '/'
              self.context = :single_line_comment
              @index += 2
            elsif @str[@index + 1] == '*'
              self.context = :multi_line_comment
              @comment_nesting = 1
              @index += 2
            else
              self.context = :ident
              @buffer = c
              @index += 1
            end
          when " ", "\t"
            self.context = :whitespace
            @buffer = c
            @index += 1
          when nil
            return [false, false] if @done
            @done = true
            return [:EOF, '']
          else
            self.context = :ident
            @buffer = c
            @index += 1
          end
        when :ident
          case c
          when /[\s=]/, nil
            case @buffer
            when 'true'  then return [:TRUE, true]
            when 'false' then return [:FALSE, false]
            when 'null'  then return [:NULL, nil]
            else return [:IDENT, @buffer]
            end
          else
            @index += 1
            @buffer += c
          end
        when :string
          case c
          when '\\'
            @buffer += c
            @buffer += @str[@index + 1]
            @index += 2
          when '"'
            @index += 1
            return [:STRING, convert_escapes(@buffer)]
          when nil
            raise Error, "Unterminated string literal"
          else
            @buffer += c
            @index += 1
          end
        when :rawstring
          raise Error, "Unterminated rawstring literal" if c.nil?

          if c == '"'
            h = 0
            while @str[@index + 1 + h] == '#' && h < @rawstring_hashes
              h += 1
            end
            if h == @rawstring_hashes
              @index += 1 + h
              return [:RAWSTRING, @buffer]
            end
          end

          @buffer += c
          @index += 1
        when :decimal
          case c
          when /[0-9.\-+_eE]/
            @index += 1
            @buffer += c
          else
            return parse_decimal(@buffer)
          end
        when :hexadecimal
          case c
          when /[0-9a-fA-F_]/
            @index += 1
            @buffer += c
          else
            return parse_hexadecimal(@buffer)
          end
        when :octal
          case c
          when /[0-7_]/
            @index += 1
            @buffer += c
          else
            return parse_octal(@buffer)
          end
        when :binary
          case c
          when /[01_]/
            @index += 1
            @buffer += c
          else
            return parse_binary(@buffer)
          end
        when :single_line_comment
          @index += 1
          if c == "\n"
            self.context = nil
          end
        when :multi_line_comment
          if c == '/' && @str[@index + 1] == '*'
            @comment_nesting += 1
            @index += 2
          elsif c == '*' && @str[@index + 1] == '/'
            @comment_nesting -= 1
            @index += 2
            if @comment_nesting == 0
              revert_context
            end
          else
            @index += 1
          end
        when :whitespace
          if c == " " || c == "\t"
            @index += 1
            @buffer += c
          elsif c == "/" && @str[@index + 1] == '*'
            self.context = :multi_line_comment
            @comment_nesting = 1
            @index += 2
          else
            return [:WS, @buffer]
          end
        end
      end
    end

    def context=(val)
      @previous_context = @context
      @context = val
    end

    def revert_context
      @context = @previous_context
      @previous_context = nil
    end

    private

    def parse_decimal(s)
      return [:FLOAT, Float(s)] if s.match?(/[.eE]/)
      [:INTEGER, Integer(s)]
    end
    
    def parse_hexadecimal(s)
      [:INTEGER, Integer(s, 16)]
    end
    
    def parse_octal(s)
      [:INTEGER, Integer(s, 8)]
    end
    
    def parse_binary(s)
      [:INTEGER, Integer(s, 2)]
    end

    def convert_escapes(string)
      string.gsub(/\\./) do |m|
        case m
        when '\n' then "\n"
        when '\t' then "\t"
        when '\r' then "\r"
        when '\b' then "\b"
        when '\f' then "\f"
        else m[1]
        end
      end
      # TODO: unicode char codes, e.g. \\u[0-9a-fA-F]{0,6}
    end
  end
end
