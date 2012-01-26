module Rays
  module Service
    module Remote
      class SSH

        def initialize(host, port, user)
          @host = host
          @port = port # TODO: not used for now.
          @user = user
          defaults
        end

        def host
          raise RaysException.new(missing_environment_option('ssh', 'host')) if @host.nil?
          @host
        end

        def port
          raise RaysException.new(missing_environment_option('ssh', 'port')) if @port.nil?
          @port
        end

        def user
          raise RaysException.new(missing_environment_option('ssh', 'user')) if @user.nil?
          @user
        end

        def exec(command)
          response = ""
          Net::SSH.start("#{host}", "#{user}") do |ssh|
            response = ssh.exec!(command)
            $log.debug(response)
          end
          response
        end

        def copy_to(local_file, remote_file)
          rays_exec("#{$rays_config.scp} #{local_file} #{user}@#{host}:#{remote_file}")
        end

        def copy_from(remote_file, local_file)
          rays_exec("#{$rays_config.scp} #{user}@#{host}:#{remote_file} #{local_file}")
        end

        private
        def defaults
          @port ||= 22
        end
      end
    end
  end
end