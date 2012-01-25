module Rays
  module AppModule
    class ThemeModule < Module
      register :theme
      directory 'themes'
      archetype 'liferay-theme-archetype'
      builder Worker::Builder::Maven.instance
      deployer Worker::Deployer::Maven.instance
      cleaner Worker::Cleaner::Maven.instance
    end
  end
end