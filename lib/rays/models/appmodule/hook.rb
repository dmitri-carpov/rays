module Rays
  module AppModule
    class HookModule < Module
      register :hook
      directory 'hooks'
      archetype 'liferay-hook-archetype'
      builder Worker::Builder::Maven.instance
      deployer Worker::Deployer::Maven.instance
      cleaner Worker::Cleaner::Maven.instance
    end
  end
end