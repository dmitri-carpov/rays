module Rays
  module Worker
    module Builder

      # Maven builder
      class Maven < BaseWorker
        register :builder, :maven
        include Singleton

        def build(app_module, skip_test = false)
          execute('build', app_module) do
            test_args = ''
            test_args = '-Dmaven.skip.tests=true' if skip_test

            rays_exec("#{$rays_config.mvn} clean package #{test_args}")
          end
        end
      end

      # Content builder
      class Content < BaseWorker
        register :builder, :content_sync
        include Singleton

        def build(app_module, skip_test = false)
          execute('build', app_module) do
            # replace liferay server port
            properties_file = Rays::Utils::FileUtils::PropertiesFile.new "#{app_module.path}/src/main/resources/configuration.properties"
            properties_file.properties['server.port'] = $rays_config.environment.liferay.port
            properties_file.write

            test_args = ''
            test_args = '-Dmaven.skip.tests=true' if skip_test

            rays_exec("cd #{app_module.path} && #{$rays_config.mvn} clean assembly:single package #{test_args}")
          end
        end
      end
    end
  end
end