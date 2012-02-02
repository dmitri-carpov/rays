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
    # Create a module
    #
    def create_module(type, name)
      log_block("create #{type} #{name}") do
        AppModule::Manager.instance.create type, name
      end
    end

    #
    # Build module(s)
    #
    def build(skip_test, modules = nil)
      log_block("build module(s)") do
        show_environment_info
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
      log_block("build and deploy module(s)") do
        show_environment_info
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
      log_block("deploy module(s)") do
        show_environment_info
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
      log_block("deploy module(s)") do
        show_environment_info
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

    #
    # Start liferay's application server
    #
    def liferay_start(force=false)
      task('starting server', 'start command has been sent', 'failed to start the server') do
        show_environment_info
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
    # Stop liferay's application server
    #
    def liferay_stop(force=false)
      task('stopping server', 'stop command has been sent', 'failed to stop the server') do
        show_environment_info
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
      log_block('get server status') do
        show_environment_info
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
      task('show server log', '', 'cannot access server log file') do
        show_environment_info
        service = $rays_config.environment.liferay.service
        service.log
      end
    end

    #
    # Clean solr index
    #
    def clean_solr_index
      log_block("clean solr index") do
        show_environment_info
        $rays_config.environment.solr.clean_all
      end
    end

    #
    # Start solr application server
    #
    def solr_start(force=false)
      task('starting server', 'start command has been sent', 'failed to start the server') do
        show_environment_info
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
      task('stopping server', 'stop command has been sent', 'failed to stop the server') do
        show_environment_info
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
      log_block('get server status') do
        show_environment_info
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
      task('show server log', '', 'cannot access server log file') do
        show_environment_info
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