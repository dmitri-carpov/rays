$global_config_path = '/tmp/.rays_config'
FileUtils.rm_rf($global_config_path) if Dir.exist?($global_config_path)

require 'rays/interface/commander'

$debug = false

#------------------------
RSpec.configure do |c|
  c.filter_run :active => true
  c.run_all_when_everything_filtered = true
end
#------------------------
module Rays
  module SpecHelper

    class TestEnvironment
      include Singleton

      attr_reader :module_types, :command

      def initialize
        unless $debug
          $log.silent_on
        else
          $log.debug_on
        end

        @module_types = {}
        @module_types[:portlet] = Rays::AppModule::PortletModule
        @module_types[:hook] = Rays::AppModule::HookModule
        @module_types[:theme] = Rays::AppModule::ThemeModule
        @module_types[:layout] = Rays::AppModule::LayoutModule

        @command = RaysCommand.new('rays')
      end
    end

    #
    # HELPER METHODS
    #

    #
    # A shortcut for commander instance.
    #
    def command
      TestEnvironment.instance.command
    end

    #
    # Get all module types for tests
    #
    def module_types
      TestEnvironment.instance.module_types
    end

    #
    # Get global config properties
    #
    def global_config
      file = File.join($global_config_path, 'global.yml')
      config = Rays::Utils::FileUtils::YamlFile.new(file)
      config.properties
    end

    #
    # Get current environment.
    #
    def env
      $rays_config.environment
    end

    #
    # Remove and create an empty new project for tests
    # This method created @project_root variable for all tests.
    #
    def recreate_test_project
      FileUtils.rm_rf($global_config_path) if Dir.exist?($global_config_path)
      project_dir_path='/tmp'
      project_name = 'test_liferay_project'
      @project_root = File.join(project_dir_path, project_name)
      remove_test_project
      in_directory(project_dir_path) do
        command.run(['new', project_name])
      end
      in_directory(@project_root) do
        Rays::Core.instance.reload
      end
    end

    #
    # Remove test project
    #
    def remove_test_project
      FileUtils.rm_rf(@project_root) if Dir.exist?(@project_root)
    end

    #
    # Stub SSH Connection to point to localhost with the currently logged user
    #
    def stub_remote deploy_dir
      ssh = Rays::Service::Remote::SSH.new 'localhost', 22, Etc.getlogin
      unless env.nil?
        env.liferay.stub(:remote).and_return ssh
        env.liferay.stub(:deploy_directory).and_return deploy_dir
      end
    end

    #
    # generate module(s)
    #
    def generate(type, name)
      module_instances = []
      module_classes = module_types.values
      module_classes = [module_types[type]] unless type.nil?
      in_directory(@project_root) do
        module_classes.each do |module_class|
          command.run(['g', module_class.type, name])
          module_instances << Rays::AppModule::Manager.instance.get(module_class.type, name)
        end
      end
      module_instances
    end

    #
    # build module(s)
    #
    def generate_and_build(type, name)
      module_instances = []
      module_classes = module_types.values
      module_classes = [module_types[type]] unless type.nil?
      in_directory(@project_root) do
        module_classes.each do |module_class|
          generate(type, name)
          command.run(['build', module_class.type, name])
          module_instances << Rays::AppModule::Manager.instance.get(module_class.type, name)
        end
      end
      module_instances
    end
  end
end
