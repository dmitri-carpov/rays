require 'find'
require 'spec_helper'

describe 'rays init' do
  include Rays::SpecHelper
  before(:all) do
    @project_root = '/tmp/test_liferay_project'
  end

  before(:each) do
    FileUtils.rm_rf(@project_root)
    FileUtils.mkdir(@project_root)
    Rays::Core.instance.reload
  end

  after(:all) do
    FileUtils.rm_rf(@project_root)
  end

  it 'should init project on the current directory' do
    in_directory(@project_root) do
      modules = []
      modules << 'portlets/test_portlet'
      modules << 'portlets/test_portlet2'
      modules << 'hooks/test_hook'      
      modules << 'hooks/test_hook2'
      modules << 'themes/test_theme'
      modules << 'themes/test_theme2'
      modules << 'layouts/test_layout'
      modules << 'layouts/test_layout2'

      modules.each do |appmodule_name|
        FileUtils.mkdir_p(appmodule_name)
      end

      lambda { command.run(%w(init)) }.should_not raise_error

      modules.each do |appmodule_name|
        File.exists?(File.join(Dir.pwd, "#{appmodule_name}/.module")).should be_true
      end
    end
  end

  it 'should not init an existing project' do
    recreate_test_project
    in_directory(@project_root) do
      lambda { command.run(%w(init)) }.should raise_error
    end

    in_directory(File.join(@project_root, 'config')) do
      lambda { command.run(%w(init)) }.should raise_error
    end
  end
end

