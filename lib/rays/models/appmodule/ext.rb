module Rays
  module AppModule
    class ExtModule < Module
      register :ext
      directory 'ext'
      archetype 'liferay-ext-archetype'
      builder Worker::Builder::Maven.instance
      deployer Worker::Deployer::Maven.instance
      cleaner Worker::Cleaner::Maven.instance
    end
  end
end
