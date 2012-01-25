module Rays
  module Server
    class LiferayServer < BaseServer

      def initialize(name, host, remote, java_home, java_bin, port, deploy_directory, application_service)
        super(name, host, remote, java_home, java_bin)
        @port = port
        @deploy_directory = deploy_directory
        @service = application_service
        default
      end

      def port
        raise RaysException.new(missing_environment_option('Liferay', 'port')) if @port.nil?
        @port
      end

      def deploy_directory
        raise RaysException.new(missing_environment_option('Liferay', 'deploy directory')) if @deploy_directory.nil?
        @deploy_directory
      end

      def service
        raise RaysException.new(missing_environment_option('Liferay', 'service')) if @service.nil?
        @service
      end

      private
      def default
        @port ||= 8080
        @deploy_directory ||= '/opt/liferay-portal/deploy'
      end
    end
  end
end