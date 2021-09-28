module KDL
  module StringDumper
    class << self
      def call(string)
        %("#{string.each_char.map { |char| escape(char) }.join}")
      end

      def stringify_identifier(ident)
        if bare_identifier?(ident)
          ident
        else
          call(ident)
        end
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
        escape_chars = '\\\/(){}<>;\[\]=,"'
        name =~ /^([^0-9\-+\s#{escape_chars}][^\s#{escape_chars}]*|[\-+](?!true|false|null)[^0-9\s#{escape_chars}][^\s#{escape_chars}]*)$/
      end
    end
  end
end
