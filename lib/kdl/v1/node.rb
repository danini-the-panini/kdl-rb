# frozen_string_literal: true

module KDL
  module V1
    class Node < ::KDL::Node
      def version
        1
      end

      def to_v1
        self
      end

      def to_v2
        ::KDL::Node.new(name,
          arguments: arguments.map(&:to_v2),
          properties: properties.transform_values(&:to_v2),
          children: children.map(&:to_v2),
          type: type
        )
      end

      private

      def id_to_s(id, m = :to_s)
        return id.public_send(m) unless m == :to_s

        StringDumper.stringify_identifier(id)
      end
    end
  end
end
