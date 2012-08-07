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
  module Worker
    module Builder

      # Liferay Maven builder
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

      # EJB Maven builder
      class EJBMaven < BaseWorker
        register :builder, :ejb_maven
        include Singleton

        def build(app_module, skip_test = false)
          execute('build', app_module) do
            test_args = ''
            test_args = '-Dmaven.skip.tests=true' if skip_test

            rays_exec("#{$rays_config.mvn} clean")
            $log.info("Installing EJB with it's client to the local maven repository")
            rays_exec("#{$rays_config.mvn} install #{test_args}")
          end
        end
      end

      # Content builder
      # deprecated
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