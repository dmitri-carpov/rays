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