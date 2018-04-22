module Warren
  module Adapters
    class Local < Base

      def fetch_nodes
        []
      end

      def node_name
        hostname
      end

    end
  end
end
