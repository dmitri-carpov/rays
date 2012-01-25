module Rays
  module Worker
    class BaseWorker
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