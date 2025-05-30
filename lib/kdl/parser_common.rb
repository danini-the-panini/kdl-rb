# frozen_string_literal: true

module KDL
  module ParserCommon

    private

    def init(parse_types: true, type_parsers: {}, output_module: ::KDL)
      @output_module = output_module
      if parse_types
        @type_parsers = ::KDL::Types::MAPPING.merge(type_parsers)
      else
        @type_parsers = {}
      end
    end

    def next_token
      @tokenizer.next_token
    end

    def check_version
      return unless doc_version = @tokenizer.version_directive
      if doc_version != parser_version
        raise VersionMismatchError.new("version mismatch, document specified v#{doc_version}, but this is a v#{parser_version} parser", doc_version, parser_version)
      end
    end

    def on_error(t, val, vstack)
      raise KDL::ParseError.new("unexpected #{token_to_str(t)} #{val&.value.inspect}", @tokenizer.filename, val&.line, val&.column)
    end
  end
end
