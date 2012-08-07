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
          enable_client_ejb module_pom
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

        def enable_client_ejb(module_pom)
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

        private
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