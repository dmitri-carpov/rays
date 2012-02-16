module Rays
  module Worker
    module Generator

      # Maven generator
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
              " -Dversion=1.0-SNAPSHOT" <<
              " -Dpackaging=war -B"
          rays_exec(create_cmd)
          MavenUtil.link_to_parent File.join(app_module.path, 'pom.xml')
        end
      end
    end
  end
end