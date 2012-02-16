module Rays
  module AppModule
    class ServiceBuilderModule < Module
      register :servicebuilder
      directory 'services'
      archetype 'liferay-servicebuilder-archetype'
      generator Worker::Manager.instance.create :generator, :maven
      builder Worker::Manager.instance.create :builder, :maven
      deployer Worker::Manager.instance.create :deployer, :maven
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end