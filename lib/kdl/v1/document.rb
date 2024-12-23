module KDL
  module V1
    class Document < ::KDL::Document
      def version
        1
      end

      def to_v1
        self
      end

      def to_v2
        ::KDL::Document.new(nodes.map(&:to_v2))
      end
    end
  end
end
