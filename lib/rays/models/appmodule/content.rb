module Rays
  module AppModule
    class ContentModule < Module
      register :content
      directory 'utils'

      builder Worker::Manager.instance.create :builder, :content_sync
      deployer Worker::Manager.instance.create :deployer, :content_sync
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end