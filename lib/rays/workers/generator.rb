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
    module Generator

      # Liferay Maven generator
      class Maven < BaseWorker
        register :generator, :maven

        include Singleton

        def create(app_module)
          raise RaysException.new("Don't know how to create #{app_module.type}/#{app_module.name}.") if app_module.archetype_name.nil?
          create_cmd = "#{$rays_config.mvn} archetype:generate" <<
              " -DarchetypeGroupId=com.liferay.maven.archetypes" <<
              " -DarchetypeArtifactId=#{app_module.archetype_name}" <<
              " -DarchetypeVersion=#{Project.instance.liferay}" <<
              " -DgroupId=#{Project.instance.package}.#{app_module.type}" <<
              " -DartifactId=#{app_module.name}" <<
              " -Dversion=#{Project.instance.version}" <<
              " -Dpackaging=war -B"
          rays_exec(create_cmd)
          Utils::FileUtils.find_down(app_module.path, 'pom\.xml').each do |pom_file|
            MavenUtil.process_pom pom_file
          end
        end
      end

      # EJB Maven generator
      class EJBMaven < BaseWorker
        register :generator, :ejb_maven

        include Singleton

        def create(app_module)
          create_cmd = "#{$rays_config.mvn} archetype:generate" <<
              " -DarchetypeGroupId=org.codehaus.mojo.archetypes" <<
              " -DarchetypeArtifactId=ejb-javaee6" <<
              " -DarchetypeVersion=1.5" <<
              " -DgroupId=#{app_module.group_id}" <<
              " -DartifactId=#{app_module.name}" <<
              " -Dversion=#{Project.instance.version}" <<
              " -Dpackaging=war -B"
          rays_exec(create_cmd)
          MavenUtil.process_ejb app_module
        end
      end
    end
  end
end