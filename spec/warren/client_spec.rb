RSpec.describe Warren::Client do

  context 'clustering' do
    before(:each) do
      cluster_one_status = {
        nodes: [{ disc: ["rabbit@ip-1-1.internal", "rabbit@ip-1-2.internal"]}],
        running_nodes: ["rabbit@ip-1-1.internal", "rabbit@ip-1-2.internal"],
        cluster_name: "rabbit@ip-1-1.internal",
        partitions: [],
        alarms: [{"rabbit@ip-1-1.internal"=>[]}, {"rabbit@ip-1-2.internal"=>[]}]
      }

      allow_any_instance_of(Warren::Client).to receive(:status).with(address: 'rabbit@ip-1-1.internal').and_return(cluster_one_status)
      allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-1-1.internal').and_return(cluster_one_status)
      allow(Warren::Node).to receive(:status).with(address: 'rabbit@ip-1-2.internal').and_return(cluster_one_status)
    end

    it 'reports as healthy' do
      client = Warren::Client.new(adapter: Warren::Adapters::Base.new)
      expect(client.clustered_with?(remote_address: 'rabbit@ip-1-2.internal')).to eq(true)
    end

    it 'can distinquish excluded nodes' do

      client = Warren::Client.new(adapter: Warren::Adapters::Base.new)
      expect(client.clustered_with?(remote_address: 'rabbit@ip-1-1.internal')).to eq(false)

    end
  end

    it 'hostname' do
      allow_any_instance_of(Warren::Adapters::AWS).to receive(:hostname).and_return("foo.bar")

      client = Warren::Client.new(adapter: Warren::Adapters::AWS.new('bla'))
      expect(client.hostname).to eq("foo.bar")

    end

end
