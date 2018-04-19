require 'warren/version'

# STL
require 'active_support/all'
require 'logger'

# App
require 'warren/config'
require 'warren/rabbitmq'
require 'warren/node'
require 'warren/client'
require 'warren/adapters/base'
require 'warren/adapters/aws'
require 'warren/adapters/local'

require 'erle'

module Warren
  class << self
    attr_writer :logger

    def root
      @root ||= Pathname.new(File.expand_path('../', __dir__))
    end

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
        log.level = Warren.config.log_level
      end
    end
  end
end
