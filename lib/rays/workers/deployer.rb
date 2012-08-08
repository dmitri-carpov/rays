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
require 'net/ssh'

module Rays
  module Worker
    module Deployer

      # Liferay Maven deployer
      class Maven < BaseWorker
        register :deployer, :maven

        include Singleton

        def deploy(app_module)
          execute('deploy', app_module) do
            env = $rays_config.environment
            Rays::Utils::FileUtils.find_down("./", '.*\\.war$').each do |file_to_deploy|
              if env.liferay.remote?
                env.liferay.remote.copy_to(file_to_deploy, env.liferay.deploy_directory)
              else
                FileUtils.cp(file_to_deploy, env.liferay.deploy_directory)
              end
            end
          end
        end
      end

      # EJB deployer
      class EJBDeploy < BaseWorker
        register :deployer, :ejb

        include Singleton

        def deploy(app_module)
          execute('deploy', app_module) do
            env = $rays_config.environment
            file_to_deploy = File.expand_path("./target/#{app_module.name}-#{Project.instance.version}.jar")
            file_to_deploy = File.expand_path("./target/#{app_module.name}.jar") unless File.exists? file_to_deploy
            if env.liferay.remote?
              env.liferay.remote.copy_to(file_to_deploy, env.liferay.service.deploy)
            else
              FileUtils.cp(file_to_deploy, env.liferay.service.deploy)
            end
          end
        end
      end

      # Content deployer
      # deprecated
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