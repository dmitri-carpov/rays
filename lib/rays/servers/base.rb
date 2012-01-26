module Rays
  module Server
    class BaseServer
      attr_reader :name

      def initialize(name, host, remote, java_home=nil, java_cmd=nil)
        @name = name
        @host = host
        @remote = remote
        @java_home = java_home
        @java_cmd = java_cmd
        default
      end

      def host
        raise RaysException.new(missing_environment_option(@name, 'host')) if @host.nil?
        @host
      end

      def java_home
        raise RaysException.new(missing_environment_option(@name, 'java home')) if @java_home.nil?
        @java_home
      end

      def java_cmd
        raise RaysException.new(missing_environment_option(@name, 'java command')) if @java_cmd.nil?
        @java_cmd
      end

      def remote?
        !@remote.nil?
      end

      def remote
        raise RaysException.new(missing_environment_option(@name, 'remote access')) if @remote.nil?
        @remote
      end

      private
      def default
        @host ||= 'localhost'
        @java_home ||= '/usr/lib/jvm/java-6-sun'
        @java_cmd ||= '/usr/bin/java'
      end
    end
  end
end