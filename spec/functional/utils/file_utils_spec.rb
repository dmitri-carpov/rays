require 'spec_helper'

describe 'file utils' do
  include Rays::SpecHelper
  before(:each) do
    @test_dir = '/tmp/rays_files_utils_test'
    Dir.mkdir(@test_dir)
  end

  after(:each) do
    FileUtils.rm_rf(@test_dir)
  end

  describe 'parent' do
    it 'should get parent of a current directory' do
      dir = '/tmp'
      parent_dir = '/'

      Rays::Utils::FileUtils.parent(dir).should == parent_dir
      Rays::Utils::FileUtils.parent(parent_dir).should == parent_dir
    end
  end

  describe 'find files' do
    it 'should find files in the hierarchy down' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('b')
        Dir.mkdir('c')
        Dir.mkdir('d')
        FileUtils.touch('c/.module')
      end

      found_files = Rays::Utils::FileUtils.find_down(@test_dir, '\.module$')
      found_files.should_not be_nil
      found_files.length.should == 1
    end

    it 'should fail to find file in the hierarchy down if file does not exist' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('b')
        Dir.mkdir('c')
        Dir.mkdir('d')
        FileUtils.touch('c/.module')
      end

      found_files = Rays::Utils::FileUtils.find_down(@test_dir, 'no_such_file')
      found_files.should_not be_nil
      found_files.length.should == 0
    end

    it 'should find a file in the hierarchy up' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('a/b')
        Dir.mkdir('a/b/c')
        Dir.mkdir('a/b/c/d')
        FileUtils.touch('a/.module')
      end

      found_files = Rays::Utils::FileUtils.find_up('.module', File.join(@test_dir, 'a/b/c/d'), @test_dir)
      found_files.should_not be_nil
      found_files.should == "#{@test_dir}/a"
    end

    it 'should find the closest file in the hierarchy up' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('a/b')
        Dir.mkdir('a/b/c')
        Dir.mkdir('a/b/c/d')
        FileUtils.touch('a/.module')
        FileUtils.touch('a/b/c/.module')
      end

      found_files = Rays::Utils::FileUtils.find_up('.module', File.join(@test_dir, 'a/b/c/d'), @test_dir)
      found_files.should_not be_nil
      found_files.should == "#{@test_dir}/a/b/c"
    end

    it 'should find a file in the hierarchy up starting from the current directory' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('a/b')
        Dir.mkdir('a/b/c')
        Dir.mkdir('a/b/c/d')
        FileUtils.touch('a/b/c/.module')
      end

      found_files = Rays::Utils::FileUtils.find_up('.module', File.join(@test_dir, 'a/b/c'), @test_dir)
      found_files.should_not be_nil
      found_files.should == "#{@test_dir}/a/b/c"
    end

    it 'should not find a file which is higher the limit by hierarchy up' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('a/b')
        Dir.mkdir('a/b/c')
        Dir.mkdir('a/b/c/d')
        FileUtils.touch('a/.module')
      end

      found_files = Rays::Utils::FileUtils.find_up('.module', File.join(@test_dir, 'a/b/c/d'), File.join(@test_dir, 'a/b'))
      found_files.should be_nil
    end

    it 'should not find not existing file by hierarchy up' do
      in_directory(@test_dir) do
        Dir.mkdir('a')
        Dir.mkdir('a/b')
        Dir.mkdir('a/b/c')
        Dir.mkdir('a/b/c/d')
        FileUtils.touch('a/.module')
      end

      found_files = Rays::Utils::FileUtils.find_up('.module_not_exist', File.join(@test_dir, 'a/b/c/d'), @test_dir)
      found_files.should be_nil
    end
  end

  describe 'find directories' do
    it 'should find child directories including hidden' do
      dirs = %w(a b c .d)
      in_directory(@test_dir) do
        dirs.each do |dir|
          FileUtils.mkdir(dir)
        end
      end
      found_dirs = Rays::Utils::FileUtils.find_directories(@test_dir, true)
      dirs.sort.should == found_dirs.sort
    end

    it 'should not find child hidden directories' do
      dirs = %w(a b c)
      hidden_dirs = %w(a b c .d)
      in_directory(@test_dir) do
        hidden_dirs.each do |dir|
          FileUtils.mkdir(dir)
        end
      end
      found_dirs = Rays::Utils::FileUtils.find_directories(@test_dir)
      dirs.sort.should == found_dirs.sort
    end
  end
end