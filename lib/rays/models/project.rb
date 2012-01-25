module Rays
  class Project

    attr_reader :name, :package

    def initialize
      project_config_file = "#{$rays_config.project_root}/config/project.yml"
      project_config = YAML::parse(File.open project_config_file).to_ruby
      @name = project_config['name']
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

        in_directory(project_root) do
          Rays::Core.instance.reload
        end
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

        Rays::Core.instance.reload

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
    end
  end
end