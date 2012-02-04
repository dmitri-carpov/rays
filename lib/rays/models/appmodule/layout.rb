module Rays
  module AppModule
    class LayoutModule < Module
      register :layout
      directory 'layouts'
      archetype 'liferay-layouttpl-archetype'
      generator Worker::Manager.instance.create :generator, :maven
      builder Worker::Manager.instance.create :builder, :maven
      deployer Worker::Manager.instance.create :deployer, :maven
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end