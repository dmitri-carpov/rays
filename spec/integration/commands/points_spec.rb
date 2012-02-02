require 'spec_helper'

describe 'points' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end


  it 'should say no points' do
    global_config['points'].should be_nil
    in_directory(@project_root) do
      $log.should_receive(:info).with('No points found')
      lambda { command.run(%w(points)) }.should_not raise_error
    end
  end

  it 'should show points' do
    global_config['points'].should be_nil
    in_directory(@project_root) do
      $log.should_receive(:info).with("default: <!#{@project_root}!>")
      command.run(%w(point))
      Rays::Core.instance.reload
      command.run(%w(points))
    end
  end
end