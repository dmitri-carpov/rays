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

require 'clamp'
require 'rays/interface/controller'

class RaysCommand < Clamp::Command
  option '--silent', :flag, 'no output information'
  option '--debug', :flag, 'debug information'

  usage '[option] command [sub-command] [command option]'

  def execute
    if debug?
      $log.debug_on
    elsif silent?
      $log.silent_on
    end
    super
  end

  #
  # OUTPUT VERSION
  #
  subcommand 'version', 'show raystool version' do

    def execute
      $log.info Gem.loaded_specs['raystool'].version
    end
  end

  #
  # CREATE A NEW PROJECT
  #
  subcommand 'new', 'create a new project' do
    parameter 'project_name', 'project name'

    def execute
      Rays::Controller.instance.create_project project_name
    end
  end

  #
  # INIT A PROJECT
  #
  subcommand 'init', 'init a project on the current directory' do
    def execute
      Rays::Controller.instance.init_project
    end
  end


  #
  # SHOW ALL MODULES
  #
  subcommand 'modules', 'show all modules' do
    def execute
      Rays::Controller.instance.show_modules
    end
  end


  #
  # GENERATORS
  #
  subcommand 'g', 'create a liferay module' do

    subcommand 'portlet', 'create a portlet' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'portlet', name, generator
      end
    end

    subcommand 'servicebuilder', 'create a service builder' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'servicebuilder', name, generator
      end
    end

    subcommand 'ext', 'create an ext plugin' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'ext', name, generator
      end
    end

    subcommand 'ejb', 'create an EJB' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'ejb', name, generator
      end
    end

    subcommand 'hook', 'create a hook' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'hook', name, generator
      end
    end

    subcommand 'theme', 'create a theme' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'theme', name, generator
      end
    end

    subcommand 'layout', 'create a layout' do
      parameter 'name', 'a module name'
      option '--generator', 'GENERATOR', 'Generator name, maven by default'

      def execute
        Rays::Controller.instance.create_module 'layout', name, generator
      end
    end
  end

  #
  # BUILDER
  #
  subcommand 'build', 'build module(s). build all modules if under project root or a specific module if under module\'s root' do
    parameter '[type]', 'a module type [portlet | hook | theme | layout | ext | ear]'
    parameter '[name]', 'a module name'
    option '--skip-test', :flag, 'use this option if you want to skip module tests'

    def execute
      modules = []
      module_name = name
      if !type.nil? and module_name.nil? and !'ear'.eql? type
        raise RaysException.new("Please specify the name of #{type}")
      end

      if 'ear'.eql? type
        module_name = 'application'
      end

      if !type.nil? and !module_name.nil?
        module_instance = Rays::AppModule::Manager.instance.get(type, module_name)
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
    parameter '[type]', 'a module type [portlet | hook | theme | layout | ext | ejb | ear]'
    parameter '[name]', 'a module name'
    option '--skip-test', :flag, 'use this option if you want to skip module tests'

    def execute
      modules = []
      module_name = name
      if !type.nil? and module_name.nil? and !'ear'.eql? type
        raise RaysException.new("Please specify the name of #{type}")
      end

      if 'ear'.eql? type
        module_name = 'application'
      end

      if !type.nil? and !module_name.nil?
        module_instance = Rays::AppModule::Manager.instance.get(type, module_name)
      else
        module_instance = Rays::AppModule::Manager.instance.get_from_path(Dir.pwd)
      end

      unless module_instance.nil?
        modules << module_instance
      else
        modules.concat(Rays::AppModule::Manager.instance.all)
        # exclude ext plugin from mass deploy
        modules.delete_if do |mod|
          mod.type.eql? 'ext' or mod.skip_mass_deploy
        end
      end

      Rays::Controller.instance.deploy skip_test?, modules
    end
  end

  #
  # CLEANER
  #
  subcommand 'clean', 'clean module(s). clean all modules if under project root or a specific module if under module\'s root' do
    parameter '[type]', 'a module type [portlet | hook | theme | layout | ext | ear]'
    parameter '[name]', 'a module name'

    def execute
      modules = []
      module_name = name
      if !type.nil? and module_name.nil? and !'ear'.eql? type
        raise RaysException.new("Please specify the name of #{type}")
      end

      if 'ear'.eql? type
        module_name = 'application'
      end

      if !type.nil? and !module_name.nil?
        module_instance = Rays::AppModule::Manager.instance.get(type, module_name)
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
      if remove?
        Rays::Controller.instance.remove_point name
      else
        Rays::Controller.instance.point Dir.pwd, name
      end
    end
  end

  subcommand 'points', 'show all points' do
    def execute
      Rays::Controller.instance.points
    end
  end


  subcommand 'go', 'switch directory using point name. use rays point to crete points' do
    parameter '[name]', 'point name. if no name is specified the point will be considered as default.'

    def execute
      Rays::Controller.instance.go name
    end
  end

  #
  # BACKUP
  #
  subcommand 'backup', 'backup current environment' do
    def execute
      Rays::Controller.instance.backup
    end
  end

  #
  # SYNC
  #
  subcommand 'sync', 'synchronize local environment with the current one' do
    def execute
      Rays::Controller.instance.sync
    end
  end


  #
  # LIFERAY
  #
  subcommand 'liferay', 'manage liferay application server' do
    parameter 'action', 'start | debug | stop | status | log | restart | restart-debug'
    option '--force', :flag, 'use it only to [start | stop] remote servers. be careful!'

    def execute
      if action.eql? 'start'
        Rays::Controller.instance.liferay_start(force?)
      elsif action.eql? 'debug'
        Rays::Controller.instance.liferay_debug(force?)
      elsif action.eql? 'restart'
        Rays::Controller.instance.liferay_restart(force?)
      elsif action.eql? 'restart-debug'
        Rays::Controller.instance.liferay_restart_debug(force?)
      elsif action.eql? 'stop'
        Rays::Controller.instance.liferay_stop(force?)
      elsif action.eql? 'status'
        Rays::Controller.instance.liferay_status
      elsif action.eql? 'log'
        Rays::Controller.instance.liferay_log
      else
        $log.error('Wrong command. see <!rays liferay --help!>.')
      end
    end
  end

  #
  # SOLR
  #
  subcommand 'solr', 'manage solr server of the current environment' do
    subcommand 'clean', 'delete all records from the solr index' do
      def execute
        Rays::Controller.instance.clean_solr_index
      end
    end

    subcommand 'start', 'start solr server' do
      option '--force', :flag, 'use it only to start a remote server. be careful!'

      def execute
        Rays::Controller.instance.solr_start(force?)
      end
    end

    subcommand 'stop', 'stop solr server' do
      option '--force', :flag, 'use it only to stop a remote server. be careful!'

      def execute
        Rays::Controller.instance.solr_stop(force?)
      end
    end

    subcommand 'log', 'show solr server log' do
      def execute
        Rays::Controller.instance.solr_log
      end
    end

    subcommand 'status', 'show solr server status' do
      def execute
        Rays::Controller.instance.solr_status
      end
    end
  end
end
