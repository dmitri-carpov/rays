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