module Rays
  module AppModule
    class PortletModule < Module
      register :portlet
      directory 'portlets'
      archetype 'liferay-portlet-archetype'
      builder Worker::Builder::Maven.instance
      deployer Worker::Deployer::Maven.instance
      cleaner Worker::Cleaner::Maven.instance
    end
  end
end