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
  end
end