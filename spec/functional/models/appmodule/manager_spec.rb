require 'spec_helper'

describe 'appmodule manager' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe '.get' do
    it 'should find a module' do
      name = 'test'
      module_class = module_types[:portlet]
      command.run(['g', module_class.type, name])
      manager = Rays::AppModule::Manager.instance
      module_instance = manager.get(module_class.type, name)
      module_instance.should_not be_nil
      module_instance.type.should == module_class.type
      module_instance.name.should == name
    end
  end
end