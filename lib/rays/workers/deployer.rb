require 'net/ssh'

module Rays
  module Worker
    module Deployer

      # Maven deployer
      class Maven < BaseWorker
        include Singleton

        def deploy(app_module)
          execute('deploy', app_module) do
            env = $rays_config.environment
            Rays::Utils::FileUtils.find_down("./target/", '.*\\.war$').each do |file_to_deploy|
              env.liferay.remote.copy_to(file_to_deploy, env.liferay.deploy_directory)
            end
          end
        end
      end

      # Content deployer
      class Content < BaseWorker
        include Singleton

        def deploy(app_module)
          execute('deploy', app_module) do
            env = $rays_config.environment
            base_filenames = []
            remote_dir = "/tmp/content_sync"
            env.remote.exec("rm -rf #{remote_dir} && mkdir #{remote_dir}")
            Rays::Utils::FileUtils.find_down("./target/", '.*\\.jar$').each do |file|
              env.liferay.remote.copy_to(file, remote_dir)
              base_filenames << File.basename(file)
            end
            class_path = base_filenames.join ':'
            env.liferay.remote.exec("export JAVA_HOME=#{env.liferay.java_home} && cd  #{remote_dir} && #{env.liferay.java_bin} -cp #{class_path} com.savoirfairelinux.liferay.client.UpdateStructures")
            env.liferay.remote.exec("export JAVA_HOME=#{env.liferay.java_home} && cd #{remote_dir} && #{env.liferay.java_bin} -cp #{class_path} com.savoirfairelinux.liferay.client.UpdateTemplates")
          end
        end
      end

    end
  end
end