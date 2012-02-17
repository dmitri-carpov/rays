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
    class DatabaseServer < BaseServer

      def initialize(name, host, remote, java_home, java_bin, port, db_name, username, password, type)
        super(name, host, remote, java_home, java_bin)
        @port = port
        @db_name = db_name
        @username = username
        @password = password
        @type = type

        @instance = nil
        if 'mysql'.eql?(@type)
            @instance = Rays::Database::MySQL.new @host, @port, @username, @password
        end
      end

      def port
        raise RaysException.new(missing_environment_option('Database server', 'port')) if @port.nil?
        @port
      end

      def db_name
        raise RaysException.new(missing_environment_option('Database server', 'database name')) if @db_name.nil?
        @db_name
      end

      def username
        raise RaysException.new(missing_environment_option('Database server', 'username')) if @username.nil?
        @username
      end

      def password
        raise RaysException.new(missing_environment_option('Database server', 'password')) if @password.nil?
        @password
      end

      def type
        raise RaysException.new(missing_environment_option('Database server', 'type')) if @type.nil?
        @type
      end

      def instance
        raise RaysException.new("Unknown database type #{@type}") if @instance.nil?
        @instance
      end
    end
  end
end