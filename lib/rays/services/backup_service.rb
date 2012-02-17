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
    class Backup

      def initialize(environment = $rays_config.environment)
        @environment = environment
        @backup_directory = create_backup_directory
        @dump_file_name = 'db.dump'
        @package_file = "archive-#{Time.now.to_i.to_s}.tar"
      end

      def backup
        package = ''

        service_safe(@environment.backup.stop_server) do
          database
          data
          package = pack
        end

        package
      end

      private

      def create_backup_directory
        base_directory = @environment.backup.directory
        # remove until multiple backups support
        execute("rm -rf #{base_directory}")
        execute("mkdir #{base_directory}")
        backup_directory = File.join(base_directory, Time.now.to_i.to_s)
        execute("mkdir #{backup_directory}")
        backup_directory
      end

      def execute(command)
        if @environment.liferay.remote?
          @environment.liferay.remote.exec(command)
        else
          rays_exec(command)
        end
      end

      #
      # Database backup
      #
      def database
        dump_file = File.join(@backup_directory, 'db.dump')
        task("creating database backup", "done", "failed") do
          execute(@environment.database.instance.export_command(@environment.database.db_name, dump_file))
        end
      end

      #
      # Data backup
      #
      def data
        task("creating data backup", "done", "failed") do
          execute("cp -r #{@environment.liferay.data_directory} #{@backup_directory}")
        end
      end

      def pack
        task("creating backup archive", "done", "failed") do
          execute("cd #{@backup_directory} && tar -cf #{@package_file} * && mv #{@package_file} .. && cd .. && rm -rf #{@backup_directory}")
        end
        "#{@environment.backup.directory}/#{@package_file}"
      end
    end
  end
end