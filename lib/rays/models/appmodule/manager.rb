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
  module AppModule

    #
    # Facade class for application modules.
    #
    class Manager
      include Singleton
      attr_reader :module_types

      def initialize
        @module_types = {}
      end

      #
      # Registering new application module type.
      # Normally used from inside base application module.
      #
      def register_module_type(type, module_class)
        @module_types[type] = module_class
      end

      #
      # Instantiate module which has a given directory
      #
      def get_from_path(path)
        return nil if path.nil? or !path.start_with?($rays_config.project_root)

        module_instance = nil
        directory = Utils::FileUtils.find_up '.module', path, $rays_config.project_root
        unless directory.nil?
          module_instance = get_module_from_descriptor(File.join(directory, '.module'))
        end

        module_instance
      end

      #
      # Find an application module by the given type and name.
      # Returns application module object or nil if no module is found.
      #
      def get(type, name)
        app_module = nil
        module_class = @module_types[type]
        unless module_class.nil?
          base_path = module_class.base_path
          in_directory(base_path) do
            if File.exists?(File.join(base_path, "#{name}/.module")) or 'application'.eql? name
              app_module = module_class.new(name)
            end
          end
        end
        app_module
      end

      #
      # Instantiate a module from a given descriptor file.
      #
      def get_from_descriptor(descriptor_file)
        return nil unless File.exists?(descriptor_file)
        get_module_from_descriptor(descriptor_file)
      end

      #
      # Finds all modules in the current project.
      # If type is specified it will find only the modules of a given type.
      #
      def all(type=nil)
        app_modules = []
        module_classes = []
        if type.nil?
          @module_types.each_value do |module_class|
            module_classes << module_class
          end
        else
          module_classes = @module_types[type] unless @module_types[type].nil?
        end

        module_classes.each do |module_class|
          base_path = module_class.base_path
          Utils::FileUtils.find_down(base_path, '\.module$').each do |descriptor_file|
            app_modules << get_module_from_descriptor(descriptor_file)
          end
        end

        app_modules
      end

      #
      # Create a new module or initialize if a directory exists but no .module file.
      #
      def create(type, name, generator=nil)
        module_type_class = @module_types[type]
        raise RaysException.new ("Cannot find module type #{type}") if module_type_class.nil?
        module_instance = module_type_class.new name
        module_instance.create generator
      end

      private

      def get_module_from_descriptor(descriptor_file)
        module_config = YAML::load_file(descriptor_file)
        get(module_config['type'], module_config['name'])
      end
    end
  end
end