require 'singleton'

module Rays

  class Core
    include Singleton

    def initialize
      load_third_party_dependencies
      load_system_wide_dependencies
      load_external_loaders
      load_system_wide_utilities
      load_servers
      load_services

      configure

      load_workers
      load_models
    end

    def reload
      $rays_config = Rays::Configuration.new
    end

    private
    def configure
      require 'rays/config/environment'
      require 'rays/config/configuration'
      $rays_config = Rays::Configuration.new
    end

    def load_system_wide_dependencies
      require 'rays/exceptions/rays_exception'
    end

    def load_external_loaders
      # loaders
      Dir[File.dirname(__FILE__) + '/loaders/*.rb'].each do |file|
        require "rays/loaders/#{File.basename(file)}"
      end
    end

    def load_system_wide_utilities
      require 'rays/utils/common_utils'
      require 'rays/utils/file_utils'
      require 'rays/utils/network_utils'
    end

    def load_servers
      require 'rays/servers/base'
      require 'rays/servers/liferay'
      require 'rays/servers/database'
      require 'rays/servers/solr'
    end

    def load_services
      require 'rays/services/remote'
      require 'rays/services/application_service'
      require 'rays/services/scm'
    end

    def load_workers
      require 'rays/workers/base'
      require 'rays/workers/builder'
      require 'rays/workers/deployer'
      require 'rays/workers/cleaner'
    end

    def load_models
      require 'rays/models/appmodule/manager'
      require 'rays/models/appmodule/base'
      require 'rays/models/appmodule/portlet'
      require 'rays/models/appmodule/hook'
      require 'rays/models/appmodule/theme'
      require 'rays/models/appmodule/layout'
      require 'rays/models/appmodule/content'
      require 'rays/models/project'
    end

    def load_third_party_dependencies
      require 'fileutils'
      require 'find'
      require 'yaml'
      require 'logger'
      require 'colorize'
      require 'net/ssh'
      require 'rsolr'
      require 'socket'
      require 'timeout'
    end
  end
end

# Load core
Rays::Core.instance