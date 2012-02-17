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
    class Sync

      def initialize
        @import_directory = '/tmp/rays_import'
        @dump_file_name = 'db.dump'
        @data_dir_name = 'data'
        recreate_import_directory
        @import_package = File.join(@import_directory, 'import_package.tar')
      end

      def sync(environment = $rays_config.environment)
        backup = Backup.new(environment)
        package_location = backup.backup
        task("copy backup file from #{environment.name}", 'done', 'failed') do
          environment.liferay.remote.copy_from(package_location, @import_package)
        end
        task('unpack backup file', 'done', 'failed') do
          in_directory(@import_directory) do
            rays_exec("tar -xf #{@import_package}")
            File.delete(@import_package)
          end
        end
        task('check backup integrity', 'backup looks OK', 'failed') do
          in_directory(@import_directory) do
            raise RaysException.new('Cannot find dump.db') unless File.exists?(@dump_file_name)
            raise RaysException.new('Cannot find data folder') unless Dir.exists?(@data_dir_name)
          end
        end

        in_local_environment do
          service_safe do
            # create local backup
            Backup.new.backup
            in_directory(@import_directory) do
              db = $rays_config.environment.database.instance
              db_name = $rays_config.environment.database.db_name
              begin
                rays_exec(db.delete_database_command(db_name))
              rescue => ex
                $log.warn("Cannot drop database #{db_name}")
              end
              task("re-create database #{db_name}", 'done', 'failed') do
                rays_exec(db.create_database_command(db_name))
              end
              task('import database dump', 'done', 'failed') do
                rays_exec(db.import_command(db_name, File.join(@import_directory, @dump_file_name)))
              end
              task('re-create data folder', 'done', 'failed') do
                FileUtils.rm_rf($rays_config.environment.liferay.data_directory)
                FileUtils.cp_r(@data_dir_name, $rays_config.environment.liferay.data_directory)
              end
            end
          end
        end
      end

      private
      def recreate_import_directory
        FileUtils.rm_rf(@import_directory) if Dir.exist?(@import_directory)
        FileUtils.mkdir_p(@import_directory)
      end

    end
  end
end