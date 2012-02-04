module Rays
  module AppModule
    class Module

      #
      # CLASS
      #
      class << self

        attr_reader :type, :base_directory, :archetype_name, :generate_worker, :build_worker, :deploy_worker, :clean_worker

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

        def generator(generate_worker)
          @generate_worker = generate_worker
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
      attr_reader :type, :name, :archetype_name

      def initialize(name)
        @name = name

        # transfer class properties to instance properties
        @type = self.class.type
        @archetype_name = self.class.archetype_name
        @generator = self.class.generate_worker
        @builder = self.class.build_worker
        @deployer = self.class.deploy_worker
        @cleaner = self.class.clean_worker

        descriptor = load_descriptor
        unless descriptor.nil?
          unless descriptor['builder'].nil?
            @builder = Worker::Manager.instnace.create :builder, descriptor['builder'].to_sym
          end
          unless descriptor['deployer'].nil?
            @deployer = Worker::Manager.instnace.create :deployer, descriptor['deployer'].to_sym
          end
          unless descriptor['cleaner'].nil?
            @cleaner = Worker::Manager.instnace.create :cleaner, descriptor['cleaner'].to_sym
          end
        end
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
      def create(generator_name=nil)

        if Dir.exist?(path)
          task("found <!#{@type} #{@name}!>", "", "failed to initialize <!#{@type} #{@name}!>") do
            create_descriptor
          end
        else

          generator = nil
          begin
            generator = Worker::Manager.instance.create(:generator, generator_name.to_sym) unless generator_name.nil?
          rescue RaysException
            # do nothing
          end
          generator ||= @generator

          FileUtils.mkdir_p(self.class.base_path) unless Dir.exist?(self.class.base_path)

          in_directory(self.class.base_path) do
            task("creating <!#{@type} #{@name}!>", "done", "failed") do
              generator.create self
              create_descriptor
            end
          end
        end
      end

      def path
        File.join(self.class.base_path, @name)
      end

      protected
      def descriptor_file_path
        File.join(path, '.module')
      end

      def create_descriptor
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

      def load_descriptor
        descriptor = nil
        if File.exists?(descriptor_file_path)
          descriptor = Utils::FileUtils::YamlFile.new(descriptor_file_path).properties
        end
        descriptor
      end
    end
  end
end