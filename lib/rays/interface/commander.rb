require 'clamp'
require 'rays/interface/controller'

class RaysCommand < Clamp::Command
  option '--silent', :flag, 'no output information'
  option '--debug', :flag, 'debug information'

  usage '[option] command [sub-command] [command option]'

  #
  # CREATE A NEW PROJECT
  #
  subcommand 'new', 'create a new project' do
    parameter 'project_name', 'project name'

    def execute
      process_global_options
      Rays::Controller.instance.create_project project_name
    end
  end

  #
  # INIT A PROJECT
  #
  subcommand 'init', 'init a project on the current directory' do
    def execute
      process_global_options
      Rays::Controller.instance.init_project
    end
  end

  #
  # GENERATORS
  #
  subcommand 'g', 'create a liferay module' do
    parameter 'type', 'a module type [portlet | hook | theme | layout]'
    parameter 'name', 'a module name'

    def execute
      process_global_options
      Rays::Controller.instance.create_module type, name
    end
  end

  #
  # BUILDER
  #
  subcommand 'build', 'build module(s). build all modules if under project root or a specific module if under module\'s root' do
    parameter '[type]', 'a module type [portlet | hook | theme | layout]'
    parameter '[name]', 'a module name'
    option '--skip-test', :flag, 'use this option if you want to skip module tests'

    def execute
      process_global_options
      modules = []
      if type.nil? and !name.nil?
        raise RaysException.new("Cannot build type w/o name.")
      end

      module_instance = nil
      if !type.nil? and !name.nil?
        module_instance = Rays::AppModule::Manager.instance.get(type, name)
      else
        module_instance = Rays::AppModule::Manager.instance.get_from_path(Dir.pwd)
      end

      unless module_instance.nil?
        modules << module_instance
      else
        modules.concat(Rays::AppModule::Manager.instance.all)
      end

      Rays::Controller.instance.build skip_test?, modules
    end
  end

  #
  # DEPLOYER
  #
  subcommand 'deploy', 'deploy module(s). deploy all modules if under project root or a specific module if under module\'s root' do
    parameter '[type]', 'a module type [portlet | hook | theme | layout]'
    parameter '[name]', 'a module name'
    option '--skip-test', :flag, 'use this option if you want to skip module tests'

    def execute
      process_global_options
      modules = []
      if type.nil? and !name.nil?
        raise RaysException.new("Cannot build type w/o name.")
      end

      module_instance = nil
      if !type.nil? and !name.nil?
        module_instance = Rays::AppModule::Manager.instance.get(type, name)
      else
        module_instance = Rays::AppModule::Manager.instance.get_from_path(Dir.pwd)
      end

      unless module_instance.nil?
        modules << module_instance
      else
        modules.concat(Rays::AppModule::Manager.instance.all)
      end

      Rays::Controller.instance.deploy skip_test?, modules
    end
  end

  #
  # CLEANER
  #
  subcommand 'clean', 'clean module(s). clean all modules if under project root or a specific module if under module\'s root' do
    parameter '[type]', 'a module type [portlet | hook | theme | layout]'
    parameter '[name]', 'a module name'

    def execute
      process_global_options
      modules = []
      if type.nil? and !name.nil?
        raise RaysException.new("Cannot build type w/o name.")
      end

      module_instance = nil
      if !type.nil? and !name.nil?
        module_instance = Rays::AppModule::Manager.instance.get(type, name)
      else
        module_instance = Rays::AppModule::Manager.instance.get_from_path(Dir.pwd)
      end

      unless module_instance.nil?
        modules << module_instance
      else
        modules.concat(Rays::AppModule::Manager.instance.all)
      end

      Rays::Controller.instance.clean modules
    end
  end

  #
  # Environment
  #
  subcommand 'env', 'show current environment' do
    parameter '[environment_name]', 'switch environment to the specified one'
    option '--list', :flag, 'list environments'

    def execute
      process_global_options

      if list?
        Rays::Controller.instance.list_environments
        return
      end

      if environment_name.nil?
        Rays::Controller.instance.current_environment
        return
      end

      unless environment_name.nil?
        Rays::Controller.instance.switch_environment environment_name
        return
      end

      $log.warn("cannot understand what to do")
    end
  end

  #
  # Points
  #
  subcommand 'point', 'remember current directory as a point. if no name specified it will consider the point as a default one' do
    parameter '[name]', 'point name. if no name is specified the point will be considered as default.'
    option '--remove', :flag, 'remove a point. if no name is specified the point will be considered as default.'

    def execute
      process_global_options
      if remove?
        Rays::Controller.instance.remove_point name
      else
        Rays::Controller.instance.point Dir.pwd, name
      end
    end
  end

  subcommand 'points', 'show all points' do
    def execute
      process_global_options
      Rays::Controller.instance.points
    end
  end


  subcommand 'go', 'switch directory using point name. use rays point to crete points' do
    parameter '[name]', 'point name. if no name is specified the point will be considered as default.'

    def execute
      process_global_options
      Rays::Controller.instance.go name
    end
  end

  #
  # LIFERAY
  #
  subcommand 'liferay', 'manage liferay application server' do
    parameter 'action', 'start | stop | status | log'
    option '--force', :flag, 'use it only to [start | stop] remote servers. be careful!'

    def execute
      process_global_options
      if action.eql? 'start'
        Rays::Controller.instance.liferay_start(force?)
      elsif action.eql? 'stop'
        Rays::Controller.instance.liferay_stop(force?)
      elsif action.eql? 'status'
        Rays::Controller.instance.liferay_status
      elsif action.eql? 'log'
        Rays::Controller.instance.liferay_log
      else
        $log.error('I cannot do what you ask. see <!rays liferay --help!>.')
      end
    end
  end

  #
  # SOLR
  #
  subcommand 'solr', 'manage solr server of the current environment' do
    subcommand 'clean', 'delete all records from the solr index' do
      def execute
        process_global_options
        Rays::Controller.instance.clean_solr_index
      end
    end

    subcommand 'start', 'start solr server' do
      option '--force', :flag, 'use it only to start a remote server. be careful!'

      def execute
        process_global_options
        Rays::Controller.instance.solr_start(force?)
      end
    end

    subcommand 'stop', 'stop solr server' do
      option '--force', :flag, 'use it only to stop a remote server. be careful!'

      def execute
        process_global_options
        Rays::Controller.instance.solr_stop(force?)
      end
    end

    subcommand 'log', 'show solr server log' do
      def execute
        process_global_options
        Rays::Controller.instance.solr_log
      end
    end

    subcommand 'status', 'show solr server status' do
      def execute
        process_global_options
        Rays::Controller.instance.solr_status
      end
    end
  end


  private

  #
  # OPTIONS PROCESSOR
  #
  def process_global_options
    if debug?
      $log.debug_on
    elsif silent?
      $log.silent_on
    end
  end
end