require 'spec_helper'

describe 'rays g' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  #
  # Portlet
  #
  describe 'portlet test' do
    it 'should create a portlet test' do
      should_pass_generator_for module_types[:portlet]
    end

    it 'should generate inside project directory' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      should_pass_generator_for(module_types[:portlet], hierarchy_test_dir)
    end

    it 'should fail outside of the project directory' do
      outside_project_dir = Rays::Utils::FileUtils.parent(@project_root)
      should_fail_generator_for(module_types[:portlet], outside_project_dir)
    end
  end

  #
  # Hook
  #
  describe 'hook test' do
    it 'should create a hook test' do
      should_pass_generator_for module_types[:hook]
    end

    it 'should generate inside project directory' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      should_pass_generator_for(module_types[:hook], hierarchy_test_dir)
    end

    it 'should fail outside of the project directory' do
      outside_project_dir = Rays::Utils::FileUtils.parent(@project_root)
      should_fail_generator_for(module_types[:hook], outside_project_dir)
    end
  end

  #
  # Theme
  #
  describe 'theme test' do
    it 'should create a theme test' do
      should_pass_generator_for module_types[:theme]
    end

    it 'should generate inside project directory' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      should_pass_generator_for(module_types[:theme], hierarchy_test_dir)
    end

    it 'should fail outside of the project directory' do
      outside_project_dir = Rays::Utils::FileUtils.parent(@project_root)
      in_directory(outside_project_dir) do
        Rays::Core.instance.reload
      end
      should_fail_generator_for(module_types[:theme], outside_project_dir)
    end
  end

  #
  # Layout
  #
  describe 'layout test' do
    it 'should create a layout test' do
      should_pass_generator_for module_types[:layout]
    end

    it 'should generate inside project directory' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      should_pass_generator_for(module_types[:layout], hierarchy_test_dir)
    end

    it 'should fail outside of the project directory' do
      outside_project_dir = Rays::Utils::FileUtils.parent(@project_root)
      in_directory(outside_project_dir) do
        Rays::Core.instance.reload
      end
      should_fail_generator_for(module_types[:layout], outside_project_dir)
    end
  end

  #
  # Ext
  #
  describe 'ext test' do
    it 'should create a ext test' do
      should_pass_generator_for module_types[:ext]
    end

    it 'should generate inside project directory' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      should_pass_generator_for(module_types[:ext], hierarchy_test_dir)
    end

    it 'should fail outside of the project directory' do
      outside_project_dir = Rays::Utils::FileUtils.parent(@project_root)
      should_fail_generator_for(module_types[:ext], outside_project_dir)
    end
  end

  #
  # Wrong usage
  #
  context 'wrong usage' do
    it 'should ask for a module type' do
      in_directory(@project_root) do
        lambda { command.run(%w{g}) }.should raise_error Clamp::UsageError
      end
    end

    it 'should ask for a module name' do
      in_directory(@project_root) do
        lambda { command.run(%w{g portlet}) }.should raise_error Clamp::UsageError
        lambda { command.run(%w{g hook}) }.should raise_error Clamp::UsageError
        lambda { command.run(%w{g theme}) }.should raise_error Clamp::UsageError
        lambda { command.run(%w{g layout}) }.should raise_error Clamp::UsageError
      end
    end
  end

  #
  # Helping methods
  #
  def should_pass_generator_for(module_class, root_dir=@project_root)
    name = 'test'

    in_directory(root_dir) do
      Rays::Core.instance.reload
      lambda { command.run(['g', module_class.type, name]) }.should_not raise_error
    end
    Dir.exist?("#{@project_root}/#{module_class.base_directory}/#{name}").should be_true
    File.exist?("#{@project_root}/#{module_class.base_directory}/#{name}/.module").should be_true
    File.exist?("#{@project_root}/#{module_class.base_directory}/#{name}/pom.xml").should be_true
  end

  def should_fail_generator_for(module_class, root_dir=@project_root)
    name = 'test'

    in_directory(root_dir) do
      Rays::Core.instance.reload
      lambda { command.run(['g', module_class.type, name]) }.should raise_error
    end
    Dir.exist?("#{@project_root}/#{module_class.base_directory}/#{name}").should_not be_true
  end
end
