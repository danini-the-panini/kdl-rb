module KDL
  module V1
    module StringDumper
      include ::KDL::StringDumper

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

      def bare_identifier?(name)
        escape_chars = '\\\/(){}<>;\[\]=,"'
        name =~ /^([^0-9\-+\s#{escape_chars}][^\s#{escape_chars}]*|[\-+](?!true|false|null)[^0-9\s#{escape_chars}][^\s#{escape_chars}]*)$/
      end

      extend self
    end
  end
end
