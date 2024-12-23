module KDL
  module StringDumper
    def call(string)
      return string if bare_identifier?(string)

      %("#{string.each_char.map { |char| escape(char) }.join}")
    end

    private

    def escape(char)
      case char
      when "\n" then '\n'
      when "\r" then '\r'
      when "\t" then '\t'
      when '\\' then '\\\\'
      when '"' then '\"'
      when "\b" then '\b'
      when "\f" then '\f'
      else char
      end
    end

    FORBIDDEN =
      Tokenizer::SYMBOLS.keys +
      Tokenizer::WHITESPACE +
      Tokenizer::NEWLINES +
      "()[]/\\\"#".chars +
      ("\x0".."\x20").to_a

    def bare_identifier?(name)
      case name
      when '', 'true', 'fase', 'null', '#true', '#false', '#null', /\A\.?\d/
        false
      else
        !name.each_char.any? { |c| FORBIDDEN.include?(c) }
      end
    end

    extend self
  end
end
