module Rays
  module AppModule
    class LayoutModule < Module
      register :layout
      directory 'layouts'
      archetype 'liferay-layouttpl-archetype'
      builder Worker::Builder::Maven.instance
      deployer Worker::Deployer::Maven.instance
      cleaner Worker::Cleaner::Maven.instance
    end
  end
end