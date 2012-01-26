module Rays
  module Service
    class ApplicationService

      def initialize(name, host, port, start_script, stop_script, log_file, remote)
        @name = name
        @host = host
        @port = port
        @start_script = start_script
        @stop_script = stop_script
        @log_file = log_file
        @remote = remote
      end

      def host
        raise RaysException.new(missing_environment_option('Service', 'host')) if @host.nil?
        @host
      end

      def port
        raise RaysException.new(missing_environment_option('Service', 'port')) if @port.nil?
        @port
      end

      # Start service
      def start
        unless alive?
          execute @start_script
        else
          raise RaysException.new('service is already running')
        end
      end

      # Stop service
      def stop
        if alive?
          execute @stop_script
        else
          raise RaysException.new('service is not running')
        end
      end

      # Show logs (live)
      def log
        if remote?
          remote.exec(command)
        else
          Thread.new do
            exec("tail -f #{@log_file}")
          end
        end
        $log.info("Following logs of #{@name} service on #{@host}.\nUse ctrl+c to interrupt.")
      end

      # Is the service resides on a remote service?
      # returns true if the service is on a remote server and false if the service is local.
      def remote?
        !@remote.nil?
      end

      # Is the service running?
      # Returns true is the service is running or false otherwise
      def alive?
        Utils::NetworkUtils.port_open?(@host, @port)
      end

      private

      # Executing command on local or a remote server depending on the service configuration.
      def execute(command)
        if remote?
          remote.exec(command)
        else
          rays_exec(command)
        end
      end
    end
  end
end