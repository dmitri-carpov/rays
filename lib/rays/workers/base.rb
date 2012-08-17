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
  module Worker
    class Manager
      include Singleton

      def initialize
        @workers = {}
      end

      def register(type, name, worker_class)
        @workers[type] = {} if @workers[type].nil?
        @workers[type][name] = worker_class
      end

      def create(type, name)
        if !@workers[type].nil? and !@workers[type][name].nil?
          @workers[type][name].instance
        else
          raise RaysException.new("Cannot find #{type} #{name}")
        end
      end
    end

    class BaseWorker
      def self.register(type, name)
        Manager.instance.register(type, name, self)
      end

      def execute(process, app_module)
        if app_module.nil? or !Dir.exist?(app_module.path)
          raise RaysException.new("Do not know how to #{process} <!#{app_module.inspect}!>")
        end

        in_directory(app_module.path) do
          task("#{process} <!#{app_module.type} #{app_module.name}!>", "done", "failed") do
            yield
          end
        end
      end
    end

    class MavenUtil
      class << self
        def process_pom(module_pom)
          check_parent_pom
          add_parent_pom_to module_pom
        end

        def process_ejb(app_module)
          check_parent_pom
          register_ee_module app_module
          register_ear_module app_module
          enable_client_ejb app_module
        end

        private
        def check_parent_pom
          in_directory($rays_config.project_root) do
            unless File.exists?('pom.xml')
              builder = Nokogiri::XML::Builder.new do |xml|
                xml.project {
                  xml.modelVersion '4.0.0'
                  xml.name Project.instance.name
                  xml.groupId parent_group_id
                  xml.artifactId parent_artifact_id
                  xml.version Project.instance.version
                  xml.packaging 'pom'
                  xml.properties {
                    xml << "<liferay.version>#{Project.instance.liferay}</liferay.version>"
                  }
                }
              end

              File.open('pom.xml', 'w') do |file|
                file.write(builder.to_xml)
              end

              # install parent
              rays_exec('mvn clean install')
            end
          end
        end

        def add_parent_pom_to(module_pom)
          doc = Nokogiri::XML(open(module_pom), &:noblanks)

          # remove generated liferay.version tags
          properties_node = doc.css('properties')
          unless properties_node.nil?
            properties_node.children.each do |node|
              if node.name == 'liferay.version'
                node.remove
              end
            end
          end

          if doc.css('project > parent').empty?
            parent_node = Nokogiri::XML::Node.new('parent', doc)

            group_id_node = Nokogiri::XML::Node.new('groupId', doc)
            group_id_node.content = parent_group_id
            parent_node.add_child group_id_node

            artifact_id_node = Nokogiri::XML::Node.new('artifactId', doc)
            artifact_id_node.content = parent_artifact_id
            parent_node.add_child artifact_id_node

            version_node = Nokogiri::XML::Node.new('version', doc)
            version_node.content = Project.instance.version
            parent_node.add_child version_node

            #relative_path_node = Nokogiri::XML::Node.new('relativePath', doc)
            #relative_path_node.content = '../../pom.xml'
            #parent_node.add_child relative_path_node

            doc.root.children.first.add_previous_sibling parent_node
          end

          doc.css('project > version').each do |node|
            node.remove
          end

          File.open(module_pom, 'w') { |file| file.write doc.to_xml }
        end

        #
        #   ========= EE
        #
        def register_ee_module(app_module)
          ee_pom = get_ee_pom
          module_root = app_module.path
          ee_root = File.dirname ee_pom
          relative_path = Pathname.new(module_root).relative_path_from(Pathname.new(ee_root)).to_s

          doc = Nokogiri::XML(open(ee_pom), &:noblanks)

          module_node = Nokogiri::XML::Node.new('module', doc)
          module_node.content = relative_path

          doc.css('project > modules > module').first.add_previous_sibling module_node

          File.open(ee_pom, 'w') { |file| file.write doc.to_xml }
        end

        def register_ear_module(app_module)
          ear_pom = get_ear_pom

          doc = Nokogiri::XML(open(ear_pom), &:noblanks)


          # add to dependencies
          dependency_node = Nokogiri::XML::Node.new('dependency', doc)
          group_id_node = Nokogiri::XML::Node.new('groupId', doc)
          group_id_node.content = app_module.group_id
          artifact_id_node = Nokogiri::XML::Node.new('artifactId', doc)
          artifact_id_node.content = app_module.name
          version_node = Nokogiri::XML::Node.new('version', doc)
          version_node.content = Project.instance.version
          type_node = Nokogiri::XML::Node.new('type', doc)
          type_node.content = app_module.type
          dependency_node.add_child group_id_node
          dependency_node.add_child artifact_id_node
          dependency_node.add_child version_node
          dependency_node.add_child type_node

          doc.css('project > dependencies').first.add_child dependency_node

          # add to modules
          if app_module.type.eql? 'ejb'
            module_node = Nokogiri::XML::Node.new('ejbModule', doc)
            group_id_node = Nokogiri::XML::Node.new('groupId', doc)
            group_id_node.content = app_module.group_id
            artifact_id_node = Nokogiri::XML::Node.new('artifactId', doc)
            artifact_id_node.content = app_module.name
            module_id_node = Nokogiri::XML::Node.new('moduleId', doc)
            module_id_node.content = app_module.name
            bundle_file_name_node = Nokogiri::XML::Node.new('bundleFileName', doc)
            bundle_file_name_node.content = "#{app_module.name}.jar"
            module_node.add_child group_id_node
            module_node.add_child artifact_id_node
            module_node.add_child module_id_node
            module_node.add_child bundle_file_name_node

            doc.css('project > build > plugins > plugin').each do |node|
              next unless node.css('artifactId').first.content.eql? 'maven-ear-plugin'
              node.css('configuration > modules').first.add_child module_node
            end

          end

          File.open(ear_pom, 'w') { |file| file.write doc.to_xml }
        end

        def enable_client_ejb(app_module)
          module_pom = File.join app_module.path, '/pom.xml'
          doc = Nokogiri::XML(open(module_pom), &:noblanks)

          doc.css('project > build > plugins > plugin').each do |node|
            group_id = node.css('groupId').text
            artifact_id = node.css('artifactId').text

            if group_id.eql?('org.apache.maven.plugins') and artifact_id.eql?('maven-ejb-plugin') and
                node.css('configuration > generateClient').empty?

              $log.info 'Enabling client generation for EJB module ...'
              configuration_node = node.css('configuration')

              if configuration_node.empty?
                configuration_node = Nokogiri::XML::Node.new('configuration', doc)
                node.add_child configuration_node
              else
                configuration_node = configuration_node[0]
              end

              generate_client_node = Nokogiri::XML::Node.new('generateClient', doc)
              generate_client_node.content = 'true'

              configuration_node.add_child generate_client_node

              File.open(module_pom, 'w') { |file| file.write doc.to_xml }
            end
          end
        end

        def get_ee_pom
          ee_dir = File.join $rays_config.project_root, "ee"
          FileUtils.mkdir_p ee_dir unless Dir.exists? ee_dir
          ee_pom_file = File.join ee_dir, "pom.xml"

          unless File.exist? ee_pom_file
            builder = Nokogiri::XML::Builder.new do |xml|
              xml.project(:xmlns => 'http://maven.apache.org/POM/4.0.0', :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                :'xsi:schemaLocation' => 'http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd') {

                xml.modelVersion '4.0.0'
                xml.name "#{Project.instance.name} EE Parent"
                xml.groupId "#{Project.instance.package}"
                xml.artifactId "ee-parent"
                xml.packaging 'pom'

                xml.modules {
                  xml.module 'ear'
                }
              }
            end

            File.open(ee_pom_file, 'w') { |file|  file.write builder.to_xml }
            add_parent_pom_to ee_pom_file
          end

          ee_pom_file
        end

        def get_ear_pom
          ear_dir = File.join $rays_config.project_root, "ee/ear"
          FileUtils.mkdir_p ear_dir unless Dir.exists? ear_dir
          ear_pom_file = File.join ear_dir, 'pom.xml'

          unless File.exist? ear_pom_file
            builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
              xml.project(:xmlns => 'http://maven.apache.org/POM/4.0.0', :'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                          :'xsi:schemaLocation' => 'http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd') {

                xml.modelVersion '4.0.0'

                xml._parent do
                  xml.groupId "#{Project.instance.package}"
                  xml.artifactId 'ee-parent'
                  xml.version "#{Project.instance.version}"
                  xml.relativePath '../pom.xml'
                end

                xml.name "#{Project.instance.name} EE Container"
                xml.groupId "#{Project.instance.package}.ear"
                xml.artifactId 'application'
                xml.packaging 'ear'

                xml.dependencies

                xml.build {
                  xml.plugins {
                    xml.plugin {
                      xml.groupId 'org.apache.maven.plugins'
                      xml.artifactId 'maven-ear-plugin'

                      xml.configuration {
                        xml.defaultJavaBundleDir 'APP-INF/lib'
                        xml.modules
                      }
                    }
                  }
                }
              }
            end

            doc = Nokogiri::XML(builder.to_xml, &:noblanks)
            doc.css('project > _parent').first.name = 'parent'

            File.open(ear_pom_file, 'w') { |file|  file.write doc.to_xml }

          end

          ear_pom_file
        end


        def parent_group_id
          "#{Project.instance.package}.#{Project.instance.name}"
        end

        def parent_artifact_id
          'parent'
        end
      end
    end
  end
end