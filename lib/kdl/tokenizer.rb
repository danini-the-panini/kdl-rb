require 'bigdecimal'

module KDL
  class Tokenizer
    class Error < StandardError
      def initialize(message, line, column)
        super("#{message} (#{line}:#{column})")
      end
    end

    class Token
      attr_reader :type, :value, :line, :column, :meta

      def initialize(type, value, line, column, meta = {})
        @type = type
        @value = value
        @line = line
        @column = column
        @meta = meta
      end

      def ==(other)
        return false unless other.is_a?(Token)

        type == other.type && value == other.value && line == other.line && column == other.column
      end

      def to_s
        "#{value.inspect} (#{line}:#{column})"
      end
      alias inspect to_s
    end

    attr_reader :index

    SYMBOLS = {
      '{' => :LBRACE,
      '}' => :RBRACE,
      '=' => :EQUALS,
      '＝' => :EQUALS,
      ';' => :SEMICOLON
    }

    WHITEPACE = ["\u0009", "\u0020", "\u00A0", "\u1680",
                 "\u2000", "\u2001", "\u2002", "\u2003",
                 "\u2004", "\u2005", "\u2006", "\u2007",
                 "\u2008", "\u2009", "\u200A", "\u202F",
                 "\u205F", "\u3000" ]

    NEWLINES = ["\u000A", "\u0085", "\u000C", "\u2028", "\u2029"]

    NON_IDENTIFIER_CHARS = Regexp.escape "#{SYMBOLS.keys.join('')}()/\\<>[]\","
    IDENTIFIER_CHARS = /[^#{NON_IDENTIFIER_CHARS}\x0-\x20]/
    INITIAL_IDENTIFIER_CHARS = /[^#{NON_IDENTIFIER_CHARS}0-9\x0-\x20]/

    ALLOWED_IN_TYPE = [:ident, :string, :rawstring]
    NOT_ALLOWED_AFTER_TYPE = [:single_line_comment, :multi_line_comment]

    def initialize(str, start = 0)
      @str = str
      @context = nil
      @rawstring_hashes = nil
      @index = start
      @buffer = ""
      @done = false
      @previous_context = nil
      @line = 1
      @column = 1
      @type_context = false
      @last_token = nil
    end

    def next_token
      @context = nil
      @previous_context = nil
      @line_at_start = @line
      @column_at_start = @column
      loop do
        c = @str[@index]
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
          when /[0-9\-+]/
            n = @str[@index + 1]
            if c == '0' && n =~ /[box]/
              traverse(2)
              @buffer = ''
              self.context = case n
                             when 'b' then :binary
                             when 'o' then :octal
                             when 'x' then :hexadecimal
                             end
            else
              self.context = :decimal
              traverse(1)
              @buffer = c
            end
          when '\\'
            t = Tokenizer.new(@str, @index + 1)
            la = t.next_token[0]
            if la == :NEWLINE
              @index = t.index
              new_line
            elsif la == :WS && (lan = t.next_token[0]) == :NEWLINE
              @index = t.index
              new_line
            else
              raise_error "Unexpected '\\'"
            end
          when *SYMBOLS.keys
            return token(SYMBOLS[c], c).tap { traverse(1) }
          when "\r"
            n = @str[@index + 1]
            if n == "\n"
              return token(:NEWLINE, "#{c}#{n}").tap do
                traverse(2)
                new_line
              end
            else
              return token(:NEWLINE, c).tap do
                traverse(1)
                new_line
              end
            end
          when *NEWLINES
            return token(:NEWLINE, c).tap do
              traverse(1)
              new_line
            end
          when "/"
            if @str[@index + 1] == '/'
              self.context = :single_line_comment
              traverse(2)
            elsif @str[@index + 1] == '*'
              self.context = :multi_line_comment
              @comment_nesting = 1
              traverse(2)
            elsif @str[@index + 1] == '-'
              return token(:SLASHDASH, '/-').tap { traverse(2) }
            else
              self.context = :ident
              @buffer = c
              traverse(1)
            end
          when *WHITEPACE
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
            @buffer += c
            @buffer += @str[@index + 1]
            traverse(2)
          when '"'
            return token(:STRING, convert_escapes(@buffer)).tap { traverse(1) }
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
            while @str[@index + 1 + h] == '#' && h < @rawstring_hashes
              h += 1
            end
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
          if NEWLINES.include?(c) || c == "\r"
            self.context = nil
            @column_at_start = @column
            next
          elsif c.nil?
            @done = true
            return token(:EOF, :EOF)
          else
            traverse(1)
          end
        when :multi_line_comment
          if c == '/' && @str[@index + 1] == '*'
            @comment_nesting += 1
            traverse(2)
          elsif c == '*' && @str[@index + 1] == '/'
            @comment_nesting -= 1
            traverse(2)
            if @comment_nesting == 0
              revert_context
            end
          else
            traverse(1)
          end
        when :whitespace
          if WHITEPACE.include?(c)
            traverse(1)
            @buffer += c
          elsif c == "\\"
            t = Tokenizer.new(@str, @index + 1)
            la = t.next_token[0]
            if la == :NEWLINE
              @index = t.index
              new_line
            elsif (la == :WS && (lan = t.next_token[0]) == :NEWLINE)
              @index = t.index
              new_line
            else
              raise_error "Unexpected '\\'"
            end
          elsif c == "/" && @str[@index + 1] == '*'
            self.context = :multi_line_comment
            @comment_nesting = 1
            traverse(2)
          else
            return token(:WS, @buffer)
          end
        end
      end
    end

    private

    def token(type, value, **meta)
      @last_token = [type, Token.new(type, value, @line_at_start, @column_at_start, meta)]
    end

    def traverse(n = 1)
      @column += n
      @index += n
    end

    def raise_error(message)
      raise Error.new(message, @line, @column)
    end

    def new_line
      @column = 1
      @line += 1
    end

    def context=(val)
      if @type_context && !ALLOWED_IN_TYPE.include?(val)
        raise_error "#{val} context not allowed in type declaration"
      elsif @last_token && @last_token[0] == :RPAREN && NOT_ALLOWED_AFTER_TYPE.include?(val)
        raise_error 'Comments are not allowed after a type declaration'
      end
      @previous_context = @context
      @context = val
    end

    def revert_context
      @context = @previous_context
      @previous_context = nil
    end

    def parse_decimal(s)
      return parse_float(s) if s =~ /[.E]/i

      token(:INTEGER, Integer(munch_underscores(s), 10), format: '%d')
    end

    def parse_float(s)
      match, whole, fraction, exponent = *s.match(/^([-+]?[\d_]+)(?:\.(\d+))?(?:[eE]([-+]?[\d_]+))?$/)
      raise_error "Invalid floating point value #{s}" if match.nil?

      s = munch_underscores(s)

      decimals = fraction.nil? ? 0 : fraction.size
      value = Float(s)
      scientific = value.abs >= 100 || (exponent && exponent.to_i.abs >= 2)
      if value.infinite? || (value.zero? && exponent.to_i < 0)
        token(:FLOAT, BigDecimal(s))
      else
        token(:FLOAT, value, format: scientific ? "%.#{decimals}E" : nil)
      end
    end

    def parse_hexadecimal(s)
      token(:INTEGER, Integer(munch_underscores(s), 16))
    end

    def parse_octal(s)
      token(:INTEGER, Integer(munch_underscores(s), 8))
    end

    def parse_binary(s)
      token(:INTEGER, Integer(munch_underscores(s), 2))
    end

    def munch_underscores(s)
      s.chomp('_').squeeze('_')
    end

    def convert_escapes(string)
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
