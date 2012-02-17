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
  module Server
    class LiferayServer < BaseServer

      def initialize(name, host, remote, java_home, java_bin, port, deploy_directory, data_directory, application_service)
        super(name, host, remote, java_home, java_bin)
        @port = port
        @deploy_directory = deploy_directory
        @data_directory = data_directory
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

      def data_directory
        raise RaysException.new(missing_environment_option('Liferay', 'data directory')) if @data_directory.nil?
        @data_directory
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