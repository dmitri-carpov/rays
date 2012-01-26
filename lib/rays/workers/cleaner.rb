module Rays
  module Worker
    module Cleaner

      # Maven cleaner
      class Maven < BaseWorker
        include Singleton

        def clean(app_module)
          execute('clean', app_module) do
            rays_exec("#{$rays_config.mvn} clean")
          end
        end

      end
    end
  end
end