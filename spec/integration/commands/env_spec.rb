require 'spec_helper'

describe 'env' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'no parameters' do
    it 'should show current environment' do
      name = env.name
      $log.should_receive(:info).with("<!#{name}!>")
      lambda { command.run(%w(env)) }.should_not raise_error
    end

    it 'should fail outside of a project' do
      in_directory(Rays::Utils::FileUtils.parent(@project_root)) do
        Rays::Core.instance.reload
        lambda { command.run(%w(env)) }.should raise_error RaysException
      end
    end
  end

  describe 'list' do
    it 'should show all available environments' do
      environments = []
      $rays_config.environments.values.each do |environment|
        environments << environment.name
      end

      $log.should_receive(:info).with("<!#{environments.join(' ')}!>")
      in_directory(@project_root) do
        lambda { command.run(%w(env --list)) }.should_not raise_error
      end
    end
  end

  describe 'test' do
    it 'should switch to test environment' do
      in_directory(@project_root) do
        env.name.should == 'local'
        lambda { command.run(%w(env test)) }.should_not raise_error
        Rays::Core.instance.reload
        env.name.should == 'test'
      end
    end
  end

  describe 'not_existing environment' do
    it 'should show message that no such environment and do not make any switch' do
      in_directory(@project_root) do
        lambda { command.run(%w(env not_existing_environment)) }.should raise_error RaysException
        Rays::Core.instance.reload
        env.name.should == 'local'
      end
    end
  end
end