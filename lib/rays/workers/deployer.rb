require 'net/ssh'

module Rays
  module Worker
    module Deployer

      # Maven deployer
      class Maven < BaseWorker
        register :deployer, :maven

        include Singleton

        def deploy(app_module)
          execute('deploy', app_module) do
            env = $rays_config.environment
            Rays::Utils::FileUtils.find_down("./target/", '.*\\.war$').each do |file_to_deploy|
              if env.liferay.remote?
                env.liferay.remote.copy_to(file_to_deploy, env.liferay.deploy_directory)
              else
                FileUtils.cp(file_to_deploy, env.liferay.deploy_directory)
              end
            end
          end
        end
      end

      # Content deployer
      class Content < BaseWorker
        register :deployer, :content_sync

        include Singleton

        def deploy(app_module)
          execute('deploy', app_module) do
            env = $rays_config.environment
            base_filenames = []
            deploy_dir = "/tmp/content_sync"
            if env.liferay.remote?
              env.liferay.remote.exec("rm -rf #{deploy_dir} && mkdir #{deploy_dir}")
            else
              rays_exec("rm -rf #{deploy_dir} && mkdir #{deploy_dir}")
            end
            Rays::Utils::FileUtils.find_down("./target/", '.*\\.jar$').each do |file|
              if env.liferay.remote?
                env.liferay.remote.copy_to(file, deploy_dir)
              else
                FileUtils.cp(file, env.liferay.deploy_directory)
              end
              base_filenames << File.basename(file)
            end

            class_path = base_filenames.join ':'
            structures_cmd = "export JAVA_HOME=#{env.liferay.java_home} && cd  #{deploy_dir} && #{env.liferay.java_cmd} -cp #{class_path} com.savoirfairelinux.liferay.client.UpdateStructures"
            templates_cmd = "export JAVA_HOME=#{env.liferay.java_home} && cd #{deploy_dir} && #{env.liferay.java_cmd} -cp #{class_path} com.savoirfairelinux.liferay.client.UpdateTemplates"

            if env.liferay.remote?
              env.liferay.remote.exec(structures_cmd)
              env.liferay.remote.exec(templates_cmd)
            else
              rays_exec(structures_cmd)
              rays_exec(templates_cmd)
            end

          end
        end
      end

    end
  end
end