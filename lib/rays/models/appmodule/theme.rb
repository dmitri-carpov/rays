module Rays
  module AppModule
    class ThemeModule < Module
      register :theme
      directory 'themes'
      archetype 'liferay-theme-archetype'
      generator Worker::Manager.instance.create :generator, :maven
      builder Worker::Manager.instance.create :builder, :maven
      deployer Worker::Manager.instance.create :deployer, :maven
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end