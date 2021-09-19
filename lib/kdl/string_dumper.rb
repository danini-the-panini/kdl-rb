module KDL
  module StringDumper
    class << self
      def call(string)
        s = %("#{string.each_char.map { |char| escape(char) }.join}")
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
        when '/' then '\/'
        else char
        end
      end

      def unicode_escape(char)
        "\\u{#{char.codepoints.first.to_s(16)}}"
      end
    end
  end
end
