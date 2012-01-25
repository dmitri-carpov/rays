require 'find'
require 'spec_helper'

describe 'rays new' do
  include Rays::SpecHelper
  before(:all) do
    @project_dir_path = '/tmp'
    @project_name = 'test_liferay_project'
    @project_root = File.join(@project_dir_path, @project_name)
    FileUtils.rm_rf(@project_root)
  end

  context 'without project name' do
    it 'should ask for a project name' do
      in_directory(@project_root) do
        lambda { command.run(%w{new}) }.should raise_error Clamp::UsageError
      end
    end
  end

  describe 'project' do
    it 'should create a project' do
      template_path = File.join(File.dirname(__FILE__), '../../../lib/rays/config/templates/project')
      FileUtils.rm_rf(@project_root) if Dir.exists?(@project_root)
      in_directory(@project_dir_path) do
        command.run(['new', @project_name])
      end
      Dir.exists?(@project_root).should be_true

      # create project tree
      project_tree = []
      Find.find(@project_root) do |file|
        project_tree << file.sub(@project_root, "")
      end

      # get template tree
      template_tree = []
      Find.find(template_path) do |file|
        template_tree << file.sub(template_path, "")
      end

      # check if the tree is the same
      project_tree.eql?(template_tree).should be_true

      FileUtils.rm_rf(@project_root) if Dir.exists?(@project_root)
    end
  end

  after(:all) do
    remove_test_project
  end
end

