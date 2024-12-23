module KDL
  module V1
    class Node < ::KDL::Node
      private

      def id_to_s(id, m = :to_s)
        return id.public_send(m) unless m == :to_s

        StringDumper.stringify_identifier(id)
      end
    end
  end
end
