require 'rays/core'

module Rays
  class Controller
    include Singleton

    #
    # Create new project
    #
    def create_project(project_name)
      log_block("create project #{project_name}") do
        Project.create project_name
        $log.warn("setup your project environments in #{$rays_config.project_root}/config/environment.yml")
      end
    end

    #
    # init project on the current directory
    #
    def init_project
      log_block("init project") do
        Project.init
        $log.warn("setup your project environments in #{$rays_config.project_root}/config/environment.yml")
      end
    end

    #
    # Show modules
    #
    def show_modules
      log_block("show modules") do
        AppModule::Manager.instance.all.each do |appmodule|
          $log.info("#{appmodule.type}: <!#{appmodule.name}!>")
        end
      end
    end


    #
    # Create a module
    #
    def create_module(type, name, generator)
      log_block("create #{type} #{name}") do
        AppModule::Manager.instance.create type, name, generator
      end
    end

    #
    # Build module(s)
    #
    def build(skip_test, modules = nil)
      show_environment_info
      log_block("build module(s)") do
        unless modules.nil?
          modules.each do |app_module|
            app_module.build skip_test
          end
        end
      end
    end

    #
    # Build and deploy module(s).
    #
    def deploy(skip_test, modules = nil)
      show_environment_info
      log_block("build and deploy module(s)") do
        unless modules.nil?
          modules.each do |app_module|
            app_module.build skip_test
            app_module.deploy
          end
        end
      end
    end

    #
    # Deploy module(s). No build.
    #
    def deploy_no_build(modules=nil)
      show_environment_info
      log_block("deploy module(s)") do
        unless modules.nil?
          modules.each do |app_module|
            app_module.deploy
          end
        end
      end
    end

    #
    # Clean module(s).
    #
    def clean(modules=nil)
      show_environment_info
      log_block("deploy module(s)") do
        unless modules.nil?
          modules.each do |app_module|
            app_module.clean
          end
        end
      end
    end

    #
    # Environment methods
    #
    def current_environment
      log_block("get environment name") do
        $log.info("<!#{$rays_config.environment.name}!>")
      end
    end

    def list_environments
      log_block("get environments list") do
        $log.info("<!#{$rays_config.environments.keys.join(" ")}!>")
      end
    end

    def switch_environment(env_name)
      log_block("switch environment") do
        $rays_config.environment = env_name
        $log.info("<!#{env_name}!>")
      end
    end

    #
    # Point methods
    #
    def point(path, name)
      log_block("remember a point") do
        $rays_config.point(path, name)
      end
    end

    def points
      log_block("show points") do
        unless $rays_config.points.nil?
          $rays_config.points.each_key do |point|
            $log.info("#{point}: <!#{$rays_config.points[point]}!>")
          end
        else
          $log.info('No points found')
        end
      end
    end

    def remove_point(name)
      log_block("remove a point") do
        $rays_config.remove_point(name)
      end
    end

    def go(name)
      log_block("switch directory") do
        points = $rays_config.points
        point_name = name
        point_name ||= 'default'
        if !points.nil? and points.include?(point_name)
          dir = points[point_name]
          if Dir.exists?(dir)
            $log.info("<!#{dir}!>") # tricky part. it logs to shell the directory name which will be switch by a bash script.
          else
            raise RaysException
          end
        else
          raise RaysException.new("no point #{name}. use <!rays point!> to create points")
        end
      end
    end

    def backup
      log_block("backup") do
        package = Rays::Service::Backup.new.backup
        $log.info("Backup created: <!#{package}!>")
      end
    end

    def sync
      if 'local'.eql?($rays_config.environment.name)
        $log.warn("Select not local environment to import to local.")
        return
      end
      log_block("synchronize environments") do
        Rays::Service::Sync.new.sync
      end
    end

    #
    # Start liferay's application server
    #
    def liferay_start(force=false)
      show_environment_info
      task('starting server', 'start command has been sent', 'failed to start the server') do
        service = $rays_config.environment.liferay.service
        if service.remote? and !force
          $log.warn("WARNING: you are trying to start a remote server.")
          $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
          $log.warn("Use <!--force!> option if you really want to start remote liferay server.")
          return
        end
        service.start
      end
    end

    #
    # Start liferay's application server in debug mode
    #
    def liferay_debug(force=false)
      show_environment_info
      task('starting server in debug mode', 'start debug command has been sent', 'failed to start the server in debug mode') do
        service = $rays_config.environment.liferay.service
        if service.remote? and !force
          $log.warn("WARNING: you are trying to debug a remote server.")
          $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
          $log.warn("Use <!--force!> option if you really want to start remote liferay server.")
          return
        end
        service.debug
      end
    end

    #
    # Stop liferay's application server
    #
    def liferay_stop(force=false)
      show_environment_info
      task('stopping server', 'stop command has been sent', 'failed to stop the server') do
        service = $rays_config.environment.liferay.service
        if service.remote? and !force
          $log.warn("WARNING: you are trying to stop a remote server.")
          $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
          $log.warn("Use <!--force!> option if you really want to stop remote liferay server.")
          return
        end
        service.stop
      end
    end

    #
    # Show liferay server status
    #
    def liferay_status
      show_environment_info
      log_block('get server status') do
        service = $rays_config.environment.liferay.service

        if service.alive?
          $log.info("running on #{service.host}:#{service.port}")
        else
          $log.info("stopped")
        end
      end
    end

    #
    # Show liferay server logs
    #
    def liferay_log
      show_environment_info
      task('show server log', '', 'cannot access server log file') do
        service = $rays_config.environment.liferay.service
        service.log
      end
    end

    #
    # Clean solr index
    #
    def clean_solr_index
      show_environment_info
      log_block("clean solr index") do
        $rays_config.environment.solr.clean_all
      end
    end

    #
    # Start solr application server
    #
    def solr_start(force=false)
      show_environment_info
      task('starting server', 'start command has been sent', 'failed to start the server') do
        service = $rays_config.environment.solr.service
        if service.remote? and !force
          $log.warn("WARNING: you are trying to start a remote server.")
          $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
          $log.warn("Use <!--force!> option if you really want to start a remote solr server.")
          return
        end
        service.start
      end
    end

    #
    # Stop solr application server
    #
    def solr_stop(force=false)
      show_environment_info
      task('stopping server', 'stop command has been sent', 'failed to stop the server') do
        service = $rays_config.environment.solr.service
        if service.remote? and !force
          $log.warn("WARNING: you are trying to stop a remote server.")
          $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
          $log.warn("Use <!--force!> option if you really want to stop a remote solr server.")
          return
        end
        service.stop
      end
    end

    #
    # Show solr server status
    #
    def solr_status
      show_environment_info
      log_block('get server status') do
        service = $rays_config.environment.solr.service
        if service.alive?
          $log.info("running on #{service.host}:#{service.port}")
        else
          $log.info("stopped")
        end
      end
    end

    #
    # Show solr server logs
    #
    def solr_log
      show_environment_info
      task('show server log', '', 'cannot access server log file') do
        service = $rays_config.environment.solr.service
        service.log
      end
    end

    private
    def show_environment_info
      $log.info("environment: <!#{$rays_config.environment.name}!>")
    end
  end
end