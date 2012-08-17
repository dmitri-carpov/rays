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
  module Service
    class UpdateManager

      def initialize(rays_content)
        @current_version = nil
        @rays_content = rays_content

        unless rays_content.nil?
          version_string = rays_content.properties['version']
          if !version_string.nil? and !version_string.strip.empty?
            @current_version = Gem::Version.create version_string
          end
        end

        if @current_version.nil?
          @current_version ||= Gem::Version.create '1.1.9'
          rays_content.properties['version'] = @current_version.to_s
          rays_content.write
        end

        @updaters = Hash.new
        @updaters[Gem::Version.create('1.2.0')] = 'update_1_2_0'
        @updaters[Gem::Version.create('1.2.1')] = 'update_1_2_1'
        @updaters[Gem::Version.create('1.2.2')] = 'update_1_2_2'
        @updaters[Gem::Version.create('1.2.3')] = 'update_1_2_3'
        @updaters[Gem::Version.create('1.2.4')] = 'update_1_2_4'
        @updaters[Gem::Version.create('1.2.5')] = 'update_1_2_5'
        @updaters[Gem::Version.create('1.2.6')] = 'update_1_2_6'
      end

      def check
        if @current_version < @updaters.keys.max
          $log.error "Your project version is #{@current_version.to_s}.\nYour rays version is #{@updaters.keys.max.to_s}.\nPress 'Enter' to upgrade or 'ctrl+c' to abort."
          begin
            STDIN.gets.chomp
          rescue Interrupt
            exit
          end
          update
        elsif @current_version > @updaters.keys.max
          $log.error "Your project version is higher than rays one.\nIt is highly recommended to upgrade your rays ('<!gem update raystool!>') before continue.\nPress 'Enter' to continue or 'ctrl+c' to abort."
          begin
            STDIN.gets.chomp
          rescue Interrupt
            exit
          end
        end

      end

      def update
        @updaters.keys.sort.each do |version|
          if @current_version < version
            $log.info "Updating project to version #{version.to_s}"
            begin
              self.send @updaters[version]
              sync_version version
            rescue => e
              $log.warn "Failed to update to version #{version.to_s}. Please report on http://github.com/dmitri-carpov/rays/issues"
              $log.error "\n\n#{e}.\nBacktrace:\r\n#{e.backtrace.join("\r\n")}"
              exit
            end
          end
        end
      end

      private

      def update_1_2_0
        environment = @rays_content.properties['environment']
        if !environment.nil? && !environment.empty?
          project_dir = Utils::FileUtils::find_up '.rays'
          config_dir = File.join(project_dir, 'config')
          profile_file = File.join(config_dir, '.profile')
          FileUtils.touch profile_file
          profile = Utils::FileUtils::YamlFile.new profile_file
          profile.properties['environment'] = environment
          profile.write

          $log.warn("Please add #{profile_file.sub(project_dir + '/', '')} to your scm ignore file.")
        end
        @rays_content.properties.delete('environment')
      end

      def update_1_2_1
        $log.info "Update info: now you can specify ssh hostname for liferay server if it is not the same as liferay's (web) hostname"
      end

      def update_1_2_2
        $log.info "Update info: now you can add skip_mass_deploy: true parameter to .module file to ignore this module for mass deploy"
      end

      def update_1_2_3
        $log.info "Update info: now you can use the root option in your environment.yml to get rid of absolute paths for data, deploy and service/path. Create a new project to see an example."
      end

      def update_1_2_4
        $log.info "Update info: added ejb support.
\t<!rays g ejb <module name>!> will create ee/ejb/<module name> plugin.
\t<!rays build ejb <module>!> will package and install ejb with it's client to the local maven repository.
\t<!rays install ejb <module name>!> will deploy it on a jee6 server, see deploy parameter for service."
      end

      def update_1_2_5
        $log.info "Update info: fixed ejb jar file path bug"
      end

      def update_1_2_6
        $log.info "Update info: added ear packaging"
      end

      def sync_version version
        @rays_content.properties['version'] = version.to_s
        @rays_content.write
        @current_version = version
      end
    end
  end
end