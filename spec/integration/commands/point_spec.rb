require 'spec_helper'

describe 'point' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'no parameters' do
    it 'should set current directory as default' do
      global_config['points'].should be_nil
      in_directory(@project_root) do
        lambda { command.run(%w(point)) }.should_not raise_error
        global_config['points'].should_not be_nil
        global_config['points']['default'].should_not be_nil
      end
    end

    it 'should delete a point if --remove option is specified' do
      global_config['points'].should be_nil
      in_directory(@project_root) do
        command.run(%w(point))
        global_config['points']['default'].should_not be_nil
        lambda { command.run(%w(point --remove)) } .should_not raise_error
        global_config['points']['default'].should be_nil
      end
    end
  end

  describe 'name' do
    it 'should store current directory with provided alias' do
      point_alias = 'test_project'
      global_config['points'].should be_nil
      in_directory(@project_root) do
        lambda { command.run(['point', point_alias]) }.should_not raise_error
        global_config['points'].should_not be_nil
        global_config['points'][point_alias].should_not be_nil
      end
    end

    it 'should delete a point if --remove option is specified' do
      point_alias = 'test_project'
      global_config['points'].should be_nil
      in_directory(@project_root) do
        command.run(['point', point_alias])
        global_config['points'][point_alias].should_not be_nil
        lambda { command.run(['point', '--remove', point_alias]) } .should_not raise_error
        global_config['points'][point_alias].should be_nil
      end
    end

    it 'should raise an error if try to remove non-existent point' do
      in_directory(@project_root) do
        lambda { command.run(%w(point --remove non-existent-point)) } .should raise_error RaysException
      end
    end
  end
end