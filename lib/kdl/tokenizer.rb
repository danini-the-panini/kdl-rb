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
      ';' => :SEMICOLON,
      '=' => :EQUALS
    }

    WHITESPACE = ["\u0009", "\u000B", "\u0020", "\u00A0",
                  "\u1680", "\u2000", "\u2001", "\u2002",
                  "\u2003", "\u2004", "\u2005", "\u2006",
                  "\u2007", "\u2008", "\u2009", "\u200A",
                  "\u202F", "\u205F", "\u3000" ]

    NEWLINES = ["\u000A", "\u0085", "\u000C", "\u2028", "\u2029"]

    NON_IDENTIFIER_CHARS = Regexp.escape "#{SYMBOLS.keys.join}()[]/\\\"##{WHITESPACE.join}"
    IDENTIFIER_CHARS = /[^#{NON_IDENTIFIER_CHARS}\x0-\x19]/
    INITIAL_IDENTIFIER_CHARS = /[^#{NON_IDENTIFIER_CHARS}0-9\x0-\x19]/

    FORBIDDEN = [
      *"\u0000".."\u0008",
      *"\u000E".."\u001F",
      "\u007F",
      *"\u200E".."\u200F",
      *"\u202A".."\u202E",
      *"\u2066".."\u2069",
      "\uFEFF"
    ]

    def initialize(str, start = 0)
      @str = debom(str)
      @context = nil
      @rawstring_hashes = nil
      @start = start
      @index = start
      @buffer = ""
      @done = false
      @previous_context = nil
      @line = 1
      @column = 1
      @type_context = false
      @last_token = nil
    end

    def done?
      @done
    end

    def [](i)
      @str[i].tap do |c|
        raise_error "Forbidden character: #{c.inspect}" if FORBIDDEN.include?(c)
      end
    end

    def tokens
      a = []
      while !done?
        a << next_token
      end
      a
    end

    def reset
      @index = @start
    end

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
            if self[@index + 1] == '"' && self[@index + 2] == '"'
              if self[@index + 3] == "\n"
                self.context = :multiline_string
                @buffer = ''
                traverse(4)
              else
                raise_error "Expected NEWLINE, found '#{self[@index + 3]}'"
              end
            else
              self.context = :string
              @buffer = ''
              traverse(1)
            end
          when '#'
            if self[@index + 1] == '"'
              if self[@index + 2] == '"' && self[@index + 3] == '"'
                if self[@index + 4] == "\n"
                  self.context = :multiline_rawstring
                  @rawstring_hashes = 1
                  @buffer = ''
                  traverse(5)
                  next
                else
                  raise_error "Expected NEWLINE, found '#{self[@index + 3]}'"
                end
              else
                self.context = :rawstring
                traverse(2)
                @rawstring_hashes = 1
                @buffer = ''
                next
              end
            elsif self[@index + 1] == '#'
              i = @index + 2
              @rawstring_hashes = 2
              while self[i] == '#'
                @rawstring_hashes += 1
                i += 1
              end
              if self[i] == '"'
                if self[i + 1] == '"' && self[i + 2] == '"'
                  if self[i + 3] == "\n"
                    self.context = :multiline_rawstring
                    traverse(@rawstring_hashes + 4)
                    @buffer = ''
                    next
                  else
                    raise_error "Expected NEWLINE, found '#{self[@index + 3]}'"
                  end
                else
                  self.context = :rawstring
                  traverse(@rawstring_hashes + 1)
                  @buffer = ''
                  next
                end
              end
            end
            self.context = :keyword
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
          when '='
            self.context = :equals
            @buffer = c
            traverse(1)
          when *SYMBOLS.keys
            return token(SYMBOLS[c], c).tap { traverse(1) }
          when "\r"
            n = self[@index + 1]
            if n == "\n"
              return token(:NEWLINE, "#{c}#{n}").tap do
                traverse(2)
              end
            else
              return token(:NEWLINE, c).tap do
                traverse(1)
              end
            end
          when *NEWLINES
            return token(:NEWLINE, c).tap do
              traverse(1)
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
            when 'true', 'false', 'null', 'inf', '-inf', 'nan'
              raise_error "Identifier cannot be a literal"
            when /\A\.\d/
              raise_error "Identifier cannot look like an illegal float"
            else
              return token(:IDENT, @buffer)
            end
          end
        when :keyword
          case c
          when /[a-z\-]/
            traverse(1)
            @buffer += c
          else
            case @buffer
            when '#true'  then return token(:TRUE, true)
            when '#false' then return token(:FALSE, false)
            when '#null'  then return token(:NULL, nil)
            when '#inf'   then return token(:FLOAT, Float::INFINITY)
            when '#-inf'  then return token(:FLOAT, -Float::INFINITY)
            when '#nan'   then return token(:FLOAT, Float::NAN)
            else raise_error "Unknown keyword #{@buffer.inspect}"
            end
          end
        when :string
          case c
          when '\\'
            @buffer += c
            c2 = self[@index + 1]
            @buffer += c2
            if NEWLINES.include?(c2)
              i = 2
              while NEWLINES.include?(self[@index + i])
                @buffer += self[@index + i]
                i+=1
              end
              traverse(i)
            else
              traverse(2)
            end
          when '"'
            return token(:STRING, unescape(@buffer)).tap { traverse(1) }
          when *NEWLINES
            raise_error "Unexpected newline in string literal"
          when nil
            raise_error "Unterminated string literal"
          else
            @buffer += c
            traverse(1)
          end
        when :multiline_string
          case c
          when '\\'
            @buffer += c
            @buffer += self[@index + 1]
            traverse(2)
          when '"'
            if self[@index + 1] == '"' && self[@index + 2] == '"'
              return token(:STRING, unescape_non_ws(dedent(unescape_ws(@buffer)))).tap { traverse(3) }
            end
            @buffer += c
            traverse(1)
          when nil
            raise_error "Unterminated multi-line string literal"
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
          elsif NEWLINES.include?(c)
            raise_error "Unexpected newline in rawstring literal"
          end

          @buffer += c
          traverse(1)
        when :multiline_rawstring
          raise_error "Unterminated multi-line rawstring literal" if c.nil?

          if c == '"' && self[@index + 1] == '"' && self[@index + 2] == '"' && self[@index + 3] == '#'
            h = 1
            h += 1 while self[@index + 3 + h] == '#' && h < @rawstring_hashes
            if h == @rawstring_hashes
              return token(:RAWSTRING, dedent(@buffer)).tap { traverse(3 + h) }
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
          elsif c == '='
            self.context = :equals
            @buffer += c
            traverse(1)
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
        when :equals
          t = Tokenizer.new(@str, @index)
          la = t.next_token
          if la[0] == :WS
            @buffer += la[1].value
            traverse_to(t.index)
          end
          return token(:EQUALS, @buffer)
        end
      end
    end

    private

    def token(type, value, **meta)
      @last_token = [type, Token.new(type, value, @line_at_start, @column_at_start, meta)]
    end

    def traverse(n = 1)
      n.times do |i|
        if self[@index + i] == "\n"
          @line += 1
          @column = 1
        else
          @column += 1
        end
      end
      @index += n
    end

    def traverse_to(i)
      traverse(i - @index)
    end

    def raise_error(message)
      raise Error.new(message, @line, @column)
    end

    def context=(val)
      if @type_context && !allowed_in_type?(val)
        raise_error "#{val} context not allowed in type declaration"
      elsif @last_token && @last_token[0] == :RPAREN && !allowed_after_type?(val)
        raise_error 'Comments are not allowed after a type declaration'
      end
      @previous_context = @context
      @context = val
    end

    def allowed_in_type?(val)
      %i[ident string rawstring multi_line_comment whitespace].include?(val)
    end

    def allowed_after_type?(val)
      !%i[single_line_comment].include?(val)
    end

    def revert_context
      @context = @previous_context
      @previous_context = nil
    end

    def integer_context(n)
      case n
      when 'b' then :binary
      when 'o' then :octal
      when 'x' then :hexadecimal
      end
    end

    def parse_decimal(s)
      return parse_float(s) if s =~ /[.E]/i

      token(:INTEGER, Integer(munch_underscores(s), 10), format: '%d')
    rescue
      if s[0] =~ INITIAL_IDENTIFIER_CHARS && s[1..-1].each_char.all? { |c| c =~ IDENTIFIER_CHARS }
        token(:IDENT, s)
      else
        raise
      end
    end

    def parse_float(s)
      match, _, fraction, exponent = *s.match(/^([-+]?[\d_]+)(?:\.([\d_]+))?(?:[eE]([-+]?[\d_]+))?$/)
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

    def unescape_ws(string)
      string.gsub(/\\(\\|\s+)/) do |m|
        case m
        when '\\\\' then '\\\\'
        else ''
        end
      end
    end

    UNESCAPE        = /\\(?:[#{WHITESPACE.join}#{NEWLINES.join}]+|[^u])/
    UNESCAPE_NON_WS = /\\(?:[^u])/

    def unescape_non_ws(string)
      unescape(string, UNESCAPE_NON_WS)
    end

    def unescape(string, rgx = UNESCAPE)
      string
        .gsub(rgx) { |m| replace_esc(m) }
        .gsub(/\\u\{[0-9a-fA-F]{0,6}\}/) do |m|
          i = Integer(m[3..-2], 16)
          if i < 0 || i > 0x10FFFF
            raise_error "Invalid code point #{u}"
          end
          i.chr(Encoding::UTF_8)
        end
    end

    def replace_esc(m)
      case m
      when '\n'   then "\n"
      when '\r'   then "\r"
      when '\t'   then "\t"
      when '\\\\' then "\\"
      when '\"'   then "\""
      when '\b'   then "\b"
      when '\f'   then "\f"
      when '\s'   then ' '
      when /\\[#{WHITESPACE.join}#{NEWLINES.join}]+/ then ''
      else raise_error "Unexpected escape #{m.inspect}"
      end
    end

    def dedent(string)
      lines = string.lines
      if lines.last.end_with?("\n")
        indent = ""
      else
        *lines, indent = lines
      end
      return "" if lines.empty?
      lines.map!(&:chomp)
      if !indent.empty? && indent.each_char.any? { |c| !WHITESPACE.include?(c) }
        raise_error "Invalid multiline string final line"
      end

      lines.map! do |line|
        fail = false
        match_indent = true
        whitespace = true
        line.each_char.with_index do |c, i|
          if i < indent.size
            next if c == indent[i]
            if WHITESPACE.include?(c)
              match_indent = false
            else
              fail = true
              break
            end
          else
            next if WHITESPACE.include?(c)
            if !match_indent
              fail = true
              break
            else
              whitespace = false
              break
            end
          end
        end
        raise_error "Invalid multiline string indentation" if fail

        if whitespace
          ''
        else
          line[indent.length..]
        end
      end
      lines.join("\n")
    end

    def debom(str)
      return str unless str.start_with?("\uFEFF")

      str[1..]
    end
  end
end
