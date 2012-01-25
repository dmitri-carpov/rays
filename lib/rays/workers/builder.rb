module Rays
  module Worker
    module Builder

      # Maven builder
      class Maven < BaseWorker
        include Singleton

        def build(app_module)
          execute('build', app_module) do
            rays_exec('mvn clean package')
          end
        end
      end

      # Content builder
      class Content < BaseWorker
        include Singleton

        def build(app_module)
          execute('build', app_module) do
            # replace liferay server port
            properties_file = Rays::Utils::FileUtils::PropertiesFile.new "#{app_module.path}/src/main/resources/configuration.properties"
            properties_file.properties['server.port'] = $rays_config.environment.liferay.port
            properties_file.write
            rays_exec("cd #{app_module.path} && mvn clean assembly:single package")
          end
        end
      end
    end
  end
end