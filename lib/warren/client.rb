module Warren
  class Client

    TYPES = [:disk, :ram]

    attr_reader :hostname, :node_name, :type, :cluster
    attr_reader :address # name@hostname
    attr_reader :adapter

    def initialize(adapter: , hostname: adapter.hostname, node_name: Warren.config.node_name, type: Node::TYPES.first)
      @node_name = node_name
      @adapter = adapter
      @hostname = hostname
      @type = type
      @address = "#{@node_name}@#{@hostname}"

      setup_env

      `hostname #{ENV['HOSTNAME']}`
      `echo "127.0.0.1 #{ENV['HOSTNAME']}" >> /etc/hosts`

      `mkdir -p #{ENV['RABBITMQ_MNESIA_DIR']}`
      `mkdir -p #{ENV['RABBITMQ_LOG_BASE']}`

      `rm -rf #{pid_file}`
      `chown -R rabbitmq:rabbitmq #{ENV['MNESIA_NODE_BASE_DIR']}`
      `chmod 777 #{ENV['MNESIA_NODE_BASE_DIR']}`
      `chown -R rabbitmq:rabbitmq #{ENV['RABBITMQ_LOG_BASE']}`
      `chmod 777 #{ENV['RABBITMQ_LOG_BASE']}`
    end

    def setup_env
      ENV.tap do |e|
        e['RABBITMQ_USE_LONGNAME'] = 'true'
        e['HOSTNAME'] = hostname
        e['RABBITMQ_NODENAME'] = address
        e['MNESIA_NODE_BASE_DIR'] = Warren.config.base_mnesia_dir
        e['RABBITMQ_LOG_BASE'] = Warren.config.log_base

        # TODO: Make configurable?
        e['RABBITMQ_MNESIA_DIR'] = "#{e['MNESIA_NODE_BASE_DIR']}/#{node_name}"
        e['RABBITMQ_LOGS'] = "#{e['RABBITMQ_LOG_BASE']}/#{e['RABBITMQ_NODENAME']}.info"
        e['RABBITMQ_SASL_LOGS'] = "#{e['RABBITMQ_LOG_BASE']}/#{e['RABBITMQ_NODENAME']}-sasl.info"
      end
    end

    def pid_file
      "#{ENV['MNESIA_NODE_BASE_DIR']}/#{ENV['node_name']}.pid"
    end

    def apply_policies
      Warren.config.policies.each do |policy_name, schema|
        target = schema['target'] || 'all'
        pattern = schema['pattern'] || '.*'
        policy_hash = schema['policy'] || {}
        policy = "{#{policy_hash.collect { |k, v| "\"#{k}\":\"#{v}\"" }.join(", ")}}"
        base_cmd = "--apply-to #{target} #{policy_name} \"#{pattern}\" '#{policy}'"
        Warren.logger.info "Applying policy #{base_cmd}"
        set_policy(base_cmd)
      end
    end

    def find_clusters
      adapter.find_clusters
    end

    def cluster_with(cluster: nil, nodes: [])
      Warren.logger.error("Specify at least one node to cluster with.") and return if nodes.empty?

      stop_app

      nodes.each do |node|
        begin
          node_address = "#{Warren.config.node_name}@#{node}"
          cluster_status = Node.status(address: node_address)
          response = RabbitMQ.ctl("-n #{@address} join_cluster #{node_address}", log: :info)
          cluster_name=(cluster) unless cluster.nil?
          return true
        rescue RabbitMQ::InconsistentCluster => e
          Warren.logger.error(e.message)
          Warren.logger.info RabbitMQ.ctl("-n #{node_address} forget_cluster_node #{@address}", log: :info)
          sleep 5
          retry
        rescue RabbitMQ::Nodedown => e
          Warren.logger.warn("Node down. Skipping...")
          Warren.logger.warn(e.message)
          # TODO: Clean up that node
          next
        rescue RabbitMQ::Exception => e
          Warren.logger.error(e.message)
        else
          break
        end
      end
    end

    def healthy?
      # health.match(/nodedown/)
    end

    [
      :start_app,
      :stop_app,
      :start_server,
      :stop_server,
      :clustered?,
      :cluster_name,
      :set_policy,
      :clustered_with?,
      :status,
      :cleanup,
      :cluster_name=
    ].each do |meth|
      define_method(meth) do |*args, **keyword_args|
        Node.send(meth, *args, address: @address, **keyword_args)
      end
    end

  end
end
