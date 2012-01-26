require 'spec_helper'
require 'etc'

describe 'rays deploy' do
  include Rays::SpecHelper

  before(:all) do
    @base_test_dir = '/tmp/rays_test'
    @deploy_dir = File.join(@base_test_dir, 'deploy')
    @content_dir = '/tmp/content_sync'
  end

  before(:each) do
    recreate_test_project

    in_directory(@project_root) do
      FileUtils.rm_rf(@base_test_dir) if Dir.exist?(@base_test_dir)
      FileUtils.mkdir_p(@deploy_dir)
    end

    #stub_remote @deploy_dir
  end

  describe 'no parameters' do
    it 'should deploy all modules from the project root' do
      name = 'test'
      module_instances = []
      module_types.each_key do |module_type|
        module_instances << generate(module_type, name).first
      end
      in_directory(@project_root) do
        lambda { command.run(%w(deploy)) }.should_not raise_error
      end
      module_instances.each do |module_instance|
        is_deployed(module_instance).should be_true
      end
    end

    it 'should deploy all modules if from inside project but outside a module' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      name = 'test'
      module_instances = []
      module_types.each_key do |module_type|
        module_instances << generate(module_type, name).first
      end
      in_directory(hierarchy_test_dir) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(%w(deploy)) }.should_not raise_error
      end
      module_instances.each do |module_instance|
        is_deployed(module_instance).should be_true
      end
    end

    it 'should deploy specific module from the module\'s root' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      generate(:layout, name)
      module_types[:layout].should_not_receive(:new)
      in_directory(module_instance.path) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(%w(deploy)) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a specific module from inside the module' do
      name = 'test'
      module_instance = generate(:layout, name).first
      generate(:theme, name)
      module_types[:theme].should_not_receive(:new)
      in_directory(File.join(module_instance.path, 'src')) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(%w(deploy)) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should fail if outside the project' do
      name = 'test'
      module_instance = generate(:layout, name).first
      in_directory(Rays::Utils::FileUtils.parent(@project_root)) do
        Rays::Core.instance.reload
        lambda { command.run(%w(deploy)) }.should raise_error
      end
      is_deployed(module_instance).should_not be_true
    end
  end

  #
  # Portlet
  #
  describe 'portlet test' do
    it 'should deploy a portlet from the project directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      in_directory(@project_root) do
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a portlet from the portlet directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      in_directory(module_instance.path) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a portlet inside portlet directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      in_directory(File.join(module_instance.path, 'src')) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      in_directory(Rays::Utils::FileUtils.parent(@project_root)) do
        Rays::Core.instance.reload
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should raise_error
      end
      is_deployed(module_instance).should be_false
    end

    it 'should deploy to remote' do
      pending
    end
  end

  #
  # Hook
  #
  describe 'hook test' do
    it 'should deploy a hook from the project directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      in_directory(@project_root) do
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a hook from the hook directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      in_directory(module_instance.path) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a hook inside hook directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      in_directory(File.join(module_instance.path, 'src')) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      in_directory(Rays::Utils::FileUtils.parent(@project_root)) do
        Rays::Core.instance.reload
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should raise_error
      end
      is_deployed(module_instance).should be_false
    end
  end

  #
  # Theme
  #
  describe 'theme test' do
    it 'should deploy a theme from the project directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      in_directory(@project_root) do
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a theme from the theme directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      in_directory(module_instance.path) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a theme inside theme directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      in_directory(File.join(module_instance.path, 'src')) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      in_directory(Rays::Utils::FileUtils.parent(@project_root)) do
        Rays::Core.instance.reload
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should raise_error
      end
      is_deployed(module_instance).should be_false
    end
  end

  #
  # Layout
  #
  describe 'layout test' do
    it 'should deploy a layout from the project directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      in_directory(@project_root) do
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a layout from the layout directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      in_directory(module_instance.path) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should deploy a layout inside layout directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      in_directory(File.join(module_instance.path, 'src')) do
        Rays::Core.instance.reload
        #stub_remote @deploy_dir
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should_not raise_error
      end
      is_deployed(module_instance).should be_true
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      in_directory(Rays::Utils::FileUtils.parent(@project_root)) do
        Rays::Core.instance.reload
        lambda { command.run(['deploy', module_instance.type, module_instance.name]) }.should raise_error
      end
      is_deployed(module_instance).should be_false
    end
  end

  # TODO: test for content_sync deploy

  #
  # Helping methods
  #

  def is_deployed(module_instance)
    file = File.join(@deploy_dir, "#{module_instance.name}-1.0.war")
    File.exist?(file)
  end
end