require 'spec_helper'

describe 'rays build' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'no parameters' do
    it 'should build all modules from the project root' do
      name = 'test'
      module_types.each_key do |module_type|
        module_instance = generate(module_type, name).first
        should_pass_build_test module_instance
      end
    end

    it 'should build all modules if from inside project but outside a module' do
      hierarchy_test_dir = File.join(@project_root, 'hierarchy_test')
      FileUtils.mkdir(hierarchy_test_dir) unless Dir.exist?(hierarchy_test_dir)
      name = 'test'
      module_types.each_key do |module_type|
        module_instance = generate(module_type, name)
        should_pass_build_test(module_instance.first, hierarchy_test_dir)
      end
    end

    it 'should build specific module from the module\'s root' do
      name = 'test'
      portlet_module_instance = generate(:portlet, name).first
      generate(:hook, name)
      module_types[:hook].should_not_receive(:new)
      should_pass_build_test(portlet_module_instance, portlet_module_instance.path)
    end

    it 'should build a specific module from inside the module' do
      name = 'test'
      theme_module_instance = generate(:theme, name).first
      generate(:layout, name)
      module_types[:layout].should_not_receive(:new)
      should_pass_build_test(theme_module_instance, File.join(theme_module_instance.path, 'src'))
    end

    it 'should fail if outside the project' do
      name = 'test'
      module_instance = generate(:layout, name).first
      should_fail_build_test(module_instance, Rays::Utils::FileUtils.parent(@project_root))
    end
  end

  #
  # Portlet
  #
  describe 'portlet test' do
    it 'should build a portlet from the project directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      should_pass_build_by_name_test module_instance
    end

    it 'should build a portlet from the portlet directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      should_pass_build_by_name_test module_instance, module_instance.path
    end

    it 'should build a portlet inside portlet directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      should_pass_build_by_name_test(module_instance, File.join(module_instance.path, 'src'))
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:portlet, name).first
      should_fail_build_by_name_test(module_instance, Rays::Utils::FileUtils.parent(@project_root))
    end
  end

  #
  # Hook
  #
  describe 'hook test' do
    it 'should build a hook from the project directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      should_pass_build_by_name_test module_instance
    end

    it 'should build a hook from the hook directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      should_pass_build_by_name_test module_instance, module_instance.path
    end

    it 'should build a hook inside hook directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      should_pass_build_by_name_test(module_instance, File.join(module_instance.path, 'src'))
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:hook, name).first
      should_fail_build_by_name_test(module_instance, Rays::Utils::FileUtils.parent(@project_root))
    end
  end

  #
  # Theme
  #
  describe 'theme test' do
    it 'should build a theme from the project directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      should_pass_build_by_name_test module_instance
    end

    it 'should build a theme from the theme directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      should_pass_build_by_name_test module_instance, module_instance.path
    end

    it 'should build a theme inside theme directory' do
      name = 'test'
      module_instance = generate(:theme, name).first
      should_pass_build_by_name_test(module_instance, File.join(module_instance.path, 'src'))
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:theme, name) .first
      should_fail_build_by_name_test(module_instance, Rays::Utils::FileUtils.parent(@project_root))
    end
  end

  #
  # Layout
  #
  describe 'layout test' do
    it 'should build a layout from the project directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      should_pass_build_by_name_test module_instance
    end

    it 'should build a layout from the layout directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      should_pass_build_by_name_test module_instance, module_instance.path
    end

    it 'should build a layout inside layout directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      should_pass_build_by_name_test(module_instance, File.join(module_instance.path, 'src'))
    end

    it 'should fail from outside project directory' do
      name = 'test'
      module_instance = generate(:layout, name).first
      should_fail_build_by_name_test(module_instance, Rays::Utils::FileUtils.parent(@project_root))
    end
  end

  # TODO: test for content_sync build

  #
  # Helping methods
  #

  # test if building is successful using type and name is successful
  def should_pass_build_by_name_test(module_instance, root_dir=@project_root)
    module_path = "#{@project_root}/#{module_instance.class.base_directory}/#{module_instance.name}"
    Dir.exists?(File.join(module_path, 'target')).should_not be_true
    in_directory(root_dir) do
      Rays::Core.instance.reload
      lambda { command.run(['build', module_instance.type, module_instance.name]) }.should_not raise_error
    end
    Dir.exists?(File.join(module_path, 'target')).should be_true
    File.exist?(File.join(module_path, "target/#{module_instance.name}-1.0.war")).should be_true
  end

  # test if building is failed using type and name is failed
  def should_fail_build_by_name_test(module_instance, root_dir=@project_root)
    module_path = "#{@project_root}/#{module_instance.class.base_path}/#{module_instance.name}"
    Dir.exists?(File.join(module_path, 'target')).should_not be_true
    in_directory(root_dir) do
      Rays::Core.instance.reload
      lambda { command.run(['build', module_instance.type, module_instance.name]) }.should raise_error
    end
    Dir.exists?(File.join(module_path, 'target')).should_not be_true
  end

  # test if building is successful with no parameters
  def should_pass_build_test(module_instance, root_dir=@project_root)
    module_path = "#{@project_root}/#{module_instance.class.base_directory}/#{module_instance.name}"
    Dir.exists?(File.join(module_path, 'target')).should_not be_true
    in_directory(root_dir) do
      Rays::Core.instance.reload
      command.run(%w(build))
    end

    Dir.exists?(File.join(module_path, 'target')).should be_true
    File.exist?(File.join(module_path, "target/#{module_instance.name}-1.0.war")).should be_true
  end

  # test if building is failed with no parameters
  def should_fail_build_test(module_instance, root_dir=@project_root)
    module_path = "#{@project_root}/#{module_instance.class.base_directory}/#{module_instance.name}"
    Dir.exists?(File.join(module_path, 'target')).should_not be_true
    in_directory(root_dir) do
      Rays::Core.instance.reload
      lambda { command.run(%w(build))}.should raise_error
    end
    Dir.exists?(File.join(module_path, 'target')).should_not be_true
  end
end