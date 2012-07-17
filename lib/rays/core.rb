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
      $rays_config = Rays::Configuration.new
    end

    def load_system_wide_dependencies
      require 'rays/exceptions/rays_exception'
      require 'rays/config/backup'
      require 'rays/config/environment'
      require 'rays/config/configuration'
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
      require 'rays/services/sync'
      require 'rays/services/backup_service'
      require 'rays/services/remote'
      require 'rays/services/application_service'
      require 'rays/services/scm'
      require 'rays/services/database'
      require 'rays/services/update_manager'
    end

    def load_workers
      require 'rays/workers/base'
      require 'rays/workers/generator'
      require 'rays/workers/builder'
      require 'rays/workers/deployer'
      require 'rays/workers/cleaner'
    end

    def load_models
      require 'rays/models/appmodule/manager'
      require 'rays/models/appmodule/base'
      require 'rays/models/appmodule/portlet'
      require 'rays/models/appmodule/servicebuilder'
      require 'rays/models/appmodule/ext'
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
      require 'highline'
      require 'safe_shell'
      require 'nokogiri'
    end
  end
end

# Load core
Rays::Core.instance