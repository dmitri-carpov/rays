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

        def loop_exec(command)
          begin
            Net::SSH.start("#{host}", "#{user}") do |ssh|
              ssh.open_channel do |channel|
                channel.on_data do |ch, data|
                  $log.info("<!#{data}!>")
                end
                channel.exec command
              end
              ssh.loop
            end
          rescue SystemExit, Interrupt
            # Ctrl-c
          end
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