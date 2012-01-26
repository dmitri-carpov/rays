module Rays
  module AppModule
    class Module

      #
      # CLASS
      #
      class << self

        attr_reader :type, :base_directory, :archetype_name, :build_worker, :deploy_worker, :clean_worker

        # Class initializers

        def register(type)
          @type = type.to_s
          Manager.instance.register_module_type(@type, self)
        end

        def directory(directory_name)
          @base_directory = directory_name
        end

        def archetype(archetype)
          @archetype_name = archetype
        end

        def builder(build_worker)
          @build_worker = build_worker
        end

        def deployer(deploy_worker)
          @deploy_worker = deploy_worker
        end

        def cleaner(clean_worker)
          @clean_worker = clean_worker
        end

        # Class methods

        # Get module's base directory path.
        def base_path
          File.join($rays_config.project_root, @base_directory)
        end
      end

      #
      # INSTANCE
      #
      attr_reader :type, :name

      def initialize(name)
        @name = name

        # transfer class properties to instance properties
        @type = self.class.type
        @archetype_name = self.class.archetype_name
        @builder = self.class.build_worker
        @deployer = self.class.deploy_worker
        @cleaner = self.class.clean_worker
      end

      #
      # Builder
      #
      def build(skip_test = false)
        @builder.build self, skip_test
      end

      #
      # Deploy
      #
      def deploy
        @deployer.deploy self
      end

      #
      # Clean
      #
      def clean
        @cleaner.clean self
      end

      #
      # Create a new module or initialize if a directory exists but no .module file.
      #
      def create

        if Dir.exist?(path)
          task("found <!#{@type} #{@name}!>", "", "failed to initialize <!#{@type} #{@name}!>") do
            create_descriptor
          end
        else
          raise RaysException.new("Don't know how to create #{@type}/#{@name}.") if @archetype_name.nil?

          FileUtils.mkdir_p(self.class.base_path) unless Dir.exist?(self.class.base_path)
          in_directory(self.class.base_path) do
            task("creating <!#{@type} #{@name}!>", "done", "failed") do
              create_cmd = "mvn archetype:generate" <<
                  " -DarchetypeGroupId=com.liferay.maven.archetypes" <<
                  " -DarchetypeArtifactId=#{@archetype_name}" <<
                  " -DgroupId=#{Project.instance.package}.#{@type}" <<
                  " -DartifactId=#{@name}" <<
                  " -Dversion=1.0" <<
                  " -Dpackaging=war -B"
              rays_exec(create_cmd)
              create_descriptor
            end
          end
        end
      end

      def path
        File.join(self.class.base_path, @name)
      end

      protected
      def create_descriptor
        descriptor_file_path = File.join(path, '.module')
        if File.exists?(descriptor_file_path)
          raise RaysException.new("<!#{@type} #{name}!> has already been initialized.")
        end
        content = {}
        content['name'] = @name
        content['type'] = @type
        File.open(descriptor_file_path, 'w') do |f|
          f.write(content.to_yaml)
        end
      end
    end
  end
end