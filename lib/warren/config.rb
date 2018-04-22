require 'yaml'
require 'ostruct'

module Warren
  class << self
    attr_accessor :config
  end

  DEFAULT_CONFIG = {
    "config_file": '/not/sure',
    "node_name": "rabbit",
    "policies": {},
    "base_mnesia_dir": '/var/lib/rabbitmq/mnesia',
    "log_base": '/var/lib/rabbitmq/infos',
    "log_level": Logger::INFO,
    "pid_file": '/etc/rabbitmq/server.pid'
  }

  def self.reset_config(configuration = OpenStruct.new(DEFAULT_CONFIG))
    self.config = configuration.freeze
  end

  self.reset_config

  def self.configure
    configuration = @config.dup
    yield(configuration)
    @config = configuration.freeze
  end

  def self.config_file(path)
    DEFAULT_CONFIG.merge(YAML::load_file(path))
  end

end
