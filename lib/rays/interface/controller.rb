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
      end
    end

    #
    # init project on the current directory
    #
    def init_project
      log_block("init project") do
        Project.init
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
    def build(modules = nil)
      log_block("build module(s)") do
        unless modules.nil?
          modules.each do |app_module|
            app_module.build
          end
        end
      end
    end

    #
    # Build and deploy module(s).
    #
    def deploy(modules = nil)
      log_block("build and deploy module(s)") do
        unless modules.nil?
          modules.each do |app_module|
            app_module.build
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
            #rays_exec("cd #{dir}")
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
      service = $rays_config.environment.liferay.service
      if service.remote? and !force
        $log.warn("WARNING: you are trying to start a remote server.")
        $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
        $log.warn("Use <!--force!> option if you really want to start remote liferay server.")
        return
      end
      task('starting server', 'start command has been sent', 'failed to start the server') do
        service.start
      end
    end

    #
    # Stop liferay's application server
    #
    def liferay_stop(force=false)
      service = $rays_config.environment.liferay.service
      if service.remote? and !force
        $log.warn("WARNING: you are trying to stop a remote server.")
        $log.warn("Your current environment is <!#{$rays_config.environment.name}!>.")
        $log.warn("Use <!--force!> option if you really want to stop remote liferay server.")
        return
      end
      task('stopping server', 'stop command has been sent', 'failed to stop the server') do
        service.stop
      end
    end

    #
    # Show liferay server status
    #
    def liferay_status
      service = $rays_config.environment.liferay.service
      log_block('get server status') do
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
      service = $rays_config.environment.liferay.service
      task('show server log', '', 'cannot access server log file') do
        service.log
      end
    end

    #
    # Clean solr index
    #
    def clean_solr_index
      log_block("clean solr index") do
        $rays_config.environment.solr.clean_all
      end
    end

  end
end