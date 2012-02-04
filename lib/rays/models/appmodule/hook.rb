module Rays
  module AppModule
    class HookModule < Module
      register :hook
      directory 'hooks'
      archetype 'liferay-hook-archetype'
      generator Worker::Manager.instance.create :generator, :maven
      builder Worker::Manager.instance.create :builder, :maven
      deployer Worker::Manager.instance.create :deployer, :maven
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end