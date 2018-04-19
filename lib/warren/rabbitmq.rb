module Warren
  module RabbitMQ

    class Exception < ::StandardError

      @registry = {}

      class << self
        attr_accessor :registry
        attr_accessor :string
      end

      def self.inherited(subclass)
        super
        registry[subclass.name.demodulize.underscore.to_sym] = subclass
      end

      def self.handle(error)
        if (matches = error.match(/Error: (?<error>.*)/))
          error = ERLE.to_ruby(matches[:error])
          case error
          when Hash
            error_splits = error.first
            if error_class = registry[error_splits.first&.to_sym]
              raise error_class, error_splits.last
            else
              # Warren.logger.error "Couldn't discriminate exception class for error '#{error}'"
              raise UnknownException, "Couldn't discriminate exception class for error '#{error}'"
            end
          when String
            raise Exception, error
          end
        end
      rescue ERLE::ParserError
        err_class = Exception
        if (matches = error.match(/Error: (?<error_str>[^\:]+)[\:\s]+(?<error_class>.*)/))
          err_class = registry[matches[:error_class]&.to_sym] || Exception
          error = matches[:error_str]
        end
        raise err_class, error
      end

    end

    class UnknownException < Exception
    end

    class NodeRunning < Exception
    end

    class InconsistentCluster < Exception
    end

    class Nodedown < Exception

    end

    def self.ctl(cmd, log: nil)
      response = exec_cmd(cmd, log: log)

      Exception.handle(response)

      obj = ERLE.to_ruby(response)
      # Warren.logger.warn("Obj '#{obj}'")
      uncomplicate(obj)
    rescue ::Exception => e
      Warren.logger.error "#{e.class.name}: #{cmd} => #{response}"
      {}
    end

    def self.exec_cmd(cmd, log: nil)
      # TODO: Parse for errors etc, raise?
      # TODO: "2>/dev/null" at the end of all commands?
      full_command = "rabbitmqctl -q #{cmd} 2>&1"
      Warren.logger.info("Will execute '#{full_command}'")
      Warren.logger.send(log, full_command) if log
      `#{full_command}`
    end

    def self.uncomplicate(obj)
      (obj || {}).inject(Hash.new) { |h, i| h.merge(i) }
    end

  end
end
