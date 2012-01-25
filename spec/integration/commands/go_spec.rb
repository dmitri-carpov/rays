require 'spec_helper'

describe 'go' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'no parameters' do
    it 'should go to default point' do
      in_directory(@project_root) do
        command.run(%w(point))
      end
      in_directory('/') do
        Rays::Core.instance.reload
        $log.should_receive(:info).with("<!#{@project_root}!>")
        lambda { command.run(%w(go)) }.should_not raise_error
      end
    end
  end

  describe 'name' do
    it 'should go to directory with provided alias' do
      point_alias = 'test_point'
      in_directory(@project_root) do
        command.run(['point', point_alias])
      end
      in_directory('/') do
        Rays::Core.instance.reload
        $log.should_receive(:info).with("<!#{@project_root}!>")
        lambda { command.run(['go', point_alias]) }.should_not raise_error
      end
    end

    it 'should raise error if directory does not exist anymore' do
      point_alias = 'test_point'
      directory = File.join(@project_root, 'test_point_dir')
      FileUtils.mkdir(directory)
      in_directory(directory) do
        command.run(['point', point_alias])
      end
      in_directory('/') do
        Rays::Core.instance.reload
        FileUtils.rm_rf(directory)
        lambda { command.run(['go', point_alias]) }.should raise_error RaysException
      end
    end
  end

  describe 'not existing name' do
    it 'should say that there is no such alias and do no cd' do
      in_directory(@project_root) do
        lambda { command.run(%w(go non-existent-point)) }.should raise_error RaysException
      end
    end
  end
end