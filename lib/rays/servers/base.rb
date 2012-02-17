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