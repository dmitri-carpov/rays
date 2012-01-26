module Rays
  module Utils
    class NetworkUtils
      class << self

        def port_open?(ip, port)
          begin
            Timeout::timeout(1) do
              begin
                s = TCPSocket.new(ip, port)
                s.close
                return true
              rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
                return false
              end
            end
          rescue Timeout::Error
            return false
          end

          false
        end

      end
    end
  end
end