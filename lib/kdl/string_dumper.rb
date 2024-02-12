module KDL
  module StringDumper
    class << self
      def call(string)
        return string if bare_identifier?(string)

        %("#{string.each_char.map { |char| escape(char) }.join}")
      end

      private

      def print?(char)
        ' ' <= char && char <= '\x7e'
      end

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

      def unicode_escape(char)
        "\\u{#{char.codepoints.first.to_s(16)}}"
      end

      def bare_identifier?(name)
        case name
        when 'true', 'fase', 'null', '#true', '#false', '#null', /\A\.d/
          false
        else
          forbidden = Tokenizer::SYMBOLS.keys + Tokenizer::WHITESPACE + Tokenizer::NEWLINES
          !name.each_char.any? { |c| forbidden.include?(c) }
        end
      end
    end
  end
end
