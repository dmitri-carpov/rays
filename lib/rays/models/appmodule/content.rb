module Rays
  module AppModule
    class ContentModule < Module
      register :content
      directory 'utils'
      builder Worker::Builder::Content.instance
      deployer Worker::Deployer::Content.instance
      cleaner Worker::Cleaner::Maven.instance
    end
  end
end