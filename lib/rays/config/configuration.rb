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

  class Configuration
    attr_reader :points

    #
    # Create Configuration object
    #
    def initialize
      @debug = false
      @silent = false
      $global_config_path ||= "#{ENV['HOME']}/.rays_config"
      @global_config_file = nil

      init_global_config

      init_project_root
      unless @project_root.nil?
        load_project_config
      end
    end

    #
    # Get project root or throw an exception if invoked outside of a project
    #
    def project_root
      raise RaysException.new("Cannot find project root.") if @project_root.nil? or @project_root.empty?
      @project_root
    end

    #
    # Get current environment
    #
    def environment
      project_root # check if it's inside a project dir
      raise RaysException.new("no environment is configured. see: config/environment.yml.") if @environment.nil?
      @environment
    end

    #
    # Set environment
    #
    def environment=(environment_name)
      project_root # check if it's inside a project dir
      if environments.include?(environment_name)
        yaml_file = get_profile_file
        yaml_file.properties['environment'] = environment_name
        yaml_file.write
        Core.instance.reload
      else
        raise RaysException.new("cannot find environment <!#{environment_name}!>")
      end
    end

    #
    # Get list of environments
    #
    def environments
      project_root # check if it's inside a project dir
      raise RaysException.new("no environment is configured. see: config/environment.yml.") if @environments.nil?
      @environments
    end

    #
    # Get secure copy command
    #
    def scp
      save = false
      begin
        check_command(@scp, 'usage: scp')
      rescue RaysException => e
        save = true
        $log.error(e)
        @scp = $terminal.ask('please provide the path to scp executable: ')
        retry
      end

      if save
        get_global_config.properties['scp_cmd'] = @scp
        get_global_config.write
      end

      @scp
    end

    #
    # Get maven command
    #
    def mvn
      save = false
      begin
        check_command(@mvn, 'Apache Maven', '-v')
      rescue RaysException => e
        save = true
        $log.error(e)
        @mvn = $terminal.ask('please provide the path to mvn executable: ')
        retry
      end

      if save
        get_global_config.properties['mvn_cmd'] = @mvn
        get_global_config.write
      end

      @mvn
    end

    #
    # Remember a point
    #
    def point(dir, name)
      unless Dir.exist?(dir)
        raise RaysException.new("Cannot remember a point to a directory which does not exist. directory: <!#{dir}!>")
      end

      global_config = get_global_config
      global_config.properties['points'] = Hash.new if global_config.properties['points'].nil?
      point_name = name
      point_name ||= 'default'
      global_config.properties['points'][point_name] = dir
      global_config.write
    end

    #
    # Remove a point
    #
    def remove_point(name)
      global_config = get_global_config
      global_config.properties['points'] = Hash.new if global_config.properties['points'].nil?
      point_name = name
      point_name ||= 'default'

      if global_config.properties['points'].nil? or global_config.properties['points'][point_name].nil?
        raise RaysException.new("#{name} point does not exist")
      end

      global_config.properties['points'].delete point_name
      global_config.write
    end

    private
    #
    # Initializes environments and project parameters.
    #
    def load_project_config
      log_block('load project configuration') do
        skip_version_check_commands = %w(go point points version)
        unless skip_version_check_commands.include? $command
          version_check
        end
        init_environments
      end
    end

    #
    # Logic for defining project's root.
    # It looks for a directory which contains .rays file.
    # Start looking from the current directory and up to the root.
    #
    def init_project_root
      return unless @project_root.nil?
      @project_root = Rays::Utils::FileUtils.find_up('.rays')
    end

    #
    # Check version
    #
    def version_check
      Rays::Service::UpdateManager.new(get_dot_rays_file).check
    end

    #
    # Main initialization method.
    # Load environments and set the first declared environment as default.
    #
    def init_environments
      @environments = {}
      environment_config_file = "#{@project_root}/config/environment.yml"
      environment_config = YAML::load_file(environment_config_file)


      environment_config.each_key do |code|
        #
        # liferay
        #
        liferay_server = nil
        liferay_config = environment_config[code]['liferay']
        unless liferay_config.nil?
          host = liferay_config['host']
          port = liferay_config['port']
          liferay_root = liferay_config['root']
          deploy = absolute_path(liferay_root, liferay_config['deploy'])
          data_directory = absolute_path(liferay_root, liferay_config['data'])
          remote = create_remote_for liferay_config
          java_home = nil
          java_bin = nil
          java_config = liferay_config['java']
          unless java_config.nil?
            java_home = java_config['home']
            java_bin = java_config['bin']
          end
          application_service = create_application_service_for('liferay', code, liferay_config)

          liferay_server = Server::LiferayServer.new 'liferay server', host, remote, java_home, java_bin, port, deploy, data_directory, application_service
        end

        #
        # database
        #
        database_server = nil
        database_config = environment_config[code]['database']
        unless database_config.nil?
          host = database_config['host']
          port = database_config['port']
          type = database_config['type']
          db_name = database_config['name']
          username = database_config['username']
          password = database_config['password']
          remote = create_remote_for database_config
          java_home = nil
          java_bin = nil
          java_config = liferay_config['java']
          unless java_config.nil?
            java_home = java_config['home']
            java_bin = java_config['bin']
          end
          database_server = Server::DatabaseServer.new 'database server', host, remote, java_home, java_bin, port, db_name, username, password, type
        end

        #
        # solr
        #
        solr_server = nil
        solr_config = environment_config[code]['solr']
        unless solr_config.nil?
          host = solr_config['host']
          port = solr_config['port']
          url = solr_config['url']
          remote = create_remote_for solr_config
          java_home = nil
          java_bin = nil
          java_config = liferay_config['java']
          unless java_config.nil?
            java_home = java_config['home']
            java_bin = java_config['bin']
          end
          application_service = create_application_service_for('solr', code, solr_config)

          solr_server = Server::SolrServer.new 'solr server', host, remote, java_home, java_bin, port, url, application_service
        end

        #
        # Backup
        #
        backup_config = nil
        backup_config_map = environment_config[code]['backup']
        unless backup_config_map.nil?
          directory = backup_config_map['directory']
          number_of_backups = backup_config_map['number_of_backups']
          stop = backup_config_map['stop']
          backup_config = Backup.new(directory, number_of_backups, stop)
        else
          backup_config = Backup.new(nil, nil, nil)
        end

        @environments[code] = Environment.new code, liferay_server, database_server, solr_server, backup_config
      end


      # load current environment
      yaml_file = get_profile_file
      env = yaml_file.properties['environment']
      if @environments.include?(env)
        @environment = @environments[env]
      end
      @environment ||= @environments.values.first unless @environments.values.empty?

    end

    #
    # Create application service for.
    #
    def create_application_service_for(name, code, config)
      application_service = nil
      application_service_config = config['service']
      host = config['host']
      port = config['port']
      root = config['root']
      remote = create_remote_for config
      unless application_service_config.nil?
        path = absolute_path(root, application_service_config['path'])
        deploy = application_service_config['deploy']
        deploy = absolute_path(path, deploy) unless deploy.nil?

        path = "" if path.nil?
        start_script = File.join(path, application_service_config['start_command'])
        debug_script = nil
        unless application_service_config['debug_command'].nil?
          debug_script = File.join(path, application_service_config['debug_command'])
        end
        stop_script = File.join(path, application_service_config['stop_command'])
        log_file = File.join(path, application_service_config['log_file'])

        application_remote = remote
        if code == 'local' or host == 'localhost'
          application_remote = nil
        end

        application_service = Service::ApplicationService.new name, host, port, start_script, debug_script, stop_script, log_file, application_remote, path, deploy
      end
      application_service
    end

    #
    # Create an instance of a remote service using server configuration map.
    #
    def create_remote_for(config)
      remote = nil
      if !config.nil? and !config['ssh'].nil? and !config['ssh']['user'].nil?
        host = config['ssh']['host']
        host ||= config['host']
        port = config['ssh']['port']
        user = config['ssh']['user']
        remote = Service::Remote::SSH.new host, port, user
      end
      remote
    end

    def get_dot_rays_file
      dot_rays_file = File.join(project_root, '.rays')
      Utils::FileUtils::YamlFile.new dot_rays_file
    end

    def get_profile_file
      profile_file = File.join(project_root, 'config/.profile')
      FileUtils.touch profile_file unless File.exists? profile_file
      Utils::FileUtils::YamlFile.new profile_file
    end

    #
    #  GLOBAL CONFIGURATION PROCESSING
    #

    def init_global_config
      @points = get_global_config.properties['points']
      @mvn = get_global_config.properties['maven_cmd']
      @scp = get_global_config.properties['scp_cmd']
    end

    def get_global_config
      check_global_config
      global_config_file = File.join($global_config_path, 'global.yml')
      raise RaysException.new("Cannot load global config file from #{global_config_file}") unless File.exists?(global_config_file)
      @global_config_file = Utils::FileUtils::YamlFile.new global_config_file if @global_config_file.nil?
      @global_config_file
    end

    def check_global_config
      unless Dir.exist?($global_config_path)
        FileUtils.mkdir($global_config_path)
        template_path = "#{File.expand_path(File.dirname(__FILE__))}/templates/global"
        Find.find(template_path) do |file|
          file_base_path = file.sub(template_path, "")
          next if file_base_path.empty?
          FileUtils.cp_r(file, File.join($global_config_path, file_base_path))
        end
      end
    end

    def check_command(command, validation_answer, *args)
      raise RaysException.new("#{command}: command not found") unless command?(command)
      unless rays_safe_exec(command, *args).include?(validation_answer)
        raise RaysException.new("#{command}: has unexpected format")
      end
      true
    end

    def absolute_path(root, path)
      return "" if path.nil? or path.empty?
      return path if root.nil? or root.strip.empty? or path.start_with? "/"
      "#{root}/#{path}"
    end

  end
end