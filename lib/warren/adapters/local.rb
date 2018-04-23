module Warren
  module Adapters
    class Local < Base

      def fetch_nodes
        []
      end

      def node_name
        'rabbit'
      end

    end
  end
end
