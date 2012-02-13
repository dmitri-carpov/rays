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