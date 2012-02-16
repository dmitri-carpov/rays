module Rays
  module AppModule
    class ExtModule < Module
      register :ext
      directory 'ext'
      archetype 'liferay-ext-archetype'
      generator Worker::Manager.instance.create :generator, :maven
      builder Worker::Manager.instance.create :builder, :maven
      deployer Worker::Manager.instance.create :deployer, :maven
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end