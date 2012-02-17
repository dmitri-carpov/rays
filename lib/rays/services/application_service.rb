=begin
Copyright (c) 2012 Dmitri Carpov

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

module Rays
  module Service
    class ApplicationService

      def initialize(name, host, port, start_script, debug_script, stop_script, log_file, remote)
        @name = name
        @host = host
        @port = port
        @start_script = start_script
        @debug_script = debug_script
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

      # Debug service
      def debug
        if @debug_script.nil?
          $log.warn('debug is disabled for this server')
          return
        end
        unless alive?
          execute @debug_script
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