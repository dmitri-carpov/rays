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
  class Project

    attr_reader :name, :version, :package, :liferay

    def initialize
      project_config_file = "#{$rays_config.project_root}/config/project.yml"
      project_config = YAML::load_file(project_config_file)
      @name = project_config['name']
      @version = project_config['version']
      @liferay = project_config['liferay']
      @package = project_config['package']
    end

    class << self
      #
      # Get a project instance
      #
      def instance
        self.new
      end

      #
      # Create new project with a given name
      #
      def create(name)
        project_root = File.join(Dir.pwd, name)
        raise RaysException.new("Folder name #{name} already exists") if Dir.exist?(project_root)
        unless rays_exec("mkdir #{project_root}")
          raise RaysException.new("Cannot create directory #{name}")
        end

        copy_template_to project_root
        init_project(project_root)
      end

      #
      # Parse current directory and try to initialize rays project on it.
      #
      def init
        project_root = Dir.pwd
        is_a_project = true

        begin
          $rays_config.project_root
        rescue RaysException => e
          is_a_project = false
        end

        if is_a_project
          raise RaysException.new("this project is already initialized.")
        end

        project_name = File.basename(Dir.pwd)
        $log.info("init project #{project_name}")
        copy_template_to project_root

        init_project(project_name)

        module_types = AppModule::Manager.instance.module_types
        module_types.values.each do |module_class|
          names = Utils::FileUtils.find_directories(module_class.base_path)
          unless names.nil?
            names.each do |name|
              AppModule::Manager.instance.create(module_class.type, name)
            end
          end
        end

        $log.info("done")
      end

      private
      def copy_template_to(project_root)
        template_path = "#{File.expand_path(File.dirname(__FILE__))}/../config/templates/project"
        Find.find(template_path) do |file|
          file_base_path = file.sub(template_path, "")
          next if file_base_path.empty?
          $log.info("create <!#{file_base_path}!>")
          FileUtils.cp_r(file, File.join(project_root, file_base_path))
        end
      end

      def init_project(project_root)
        in_directory(project_root) do
          project_file = Utils::FileUtils::YamlFile.new('./config/project.yml')
          project_file.properties['name'] = File.basename(project_root)
          project_file.write
          Rays::Core.instance.reload
        end
      end
    end
  end
end