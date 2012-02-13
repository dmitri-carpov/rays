module Rays
  module Database
    class MySQL
      def initialize(host, port, username, password, db_name=nil)
        @host = host
        @port = port
        @username = username
        @password = password
        @db_name = db_name
      end

      def export_command(db_name, dump_file)
        "mysqldump -u#{@username} #{pass_param} -h#{@host} --port=#{@port} #{db_name} > #{dump_file}"
      end

      def import_command(db_name, dump_file)
        "mysql -u#{@username} #{pass_param} #{db_name} < #{dump_file}"
      end

      def create_database_command(db_name)
        "mysqladmin -u#{@username} #{pass_param} create #{db_name}"
      end

      def delete_database_command(db_name)
        "mysqladmin -u#{@username} #{pass_param} -f drop #{db_name}"
      end

      private
      def pass_param
        password = ''
        password = "-p#{@password}" unless @password.nil? or @password.empty?
        password
      end
    end
  end
end