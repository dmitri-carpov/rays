module Rays
  module AppModule
    class PortletModule < Module
      register :portlet
      directory 'portlets'
      archetype 'liferay-portlet-archetype'
      generator Worker::Manager.instance.create :generator, :maven
      builder Worker::Manager.instance.create :builder, :maven
      deployer Worker::Manager.instance.create :deployer, :maven
      cleaner Worker::Manager.instance.create :cleaner, :maven
    end
  end
end