require 'spec_helper'

describe 'liferay' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'start' do
    context 'local' do
      it 'should start server when it is stopped' do
        pending
      end

      it 'should warn if server already running' do
        pending
      end

      it 'should start server when outside of project if default point points to a project' do
        pending
      end

      it 'should fail if outside of project and no default point is defined' do
        pending
      end
    end

    context 'remote' do
      it 'should start server when it is stopped' do
        pending
      end

      it 'should warn if server already running' do
        pending
      end

      it 'should start server when outside of project if default point points to a project' do
        pending
      end

      it 'should fail if outside of project and no default point is defined' do
        pending
      end
    end
  end

  describe 'stop' do
    context 'local' do
      it 'should stop server when it is running' do
        pending
      end

      it 'should warn if server is not running' do
        pending
      end

      it 'should stop server when outside of project if default point points to a project' do
        pending
      end

      it 'should fail if outside of project and no default point is defined' do
        pending
      end
    end

    context 'remote' do
      it 'should stop server when it is running' do
        pending
      end

      it 'should warn if server is not running' do
        pending
      end

      it 'should stop server when outside of project if default point points to a project' do
        pending
      end

      it 'should fail if outside of project and no default point is defined' do
        pending
      end
    end
  end

  describe 'log' do
    context 'local' do
      it 'should show the log' do
         pending
      end
    end

    context 'remote' do
      it 'should show the log' do
        pending
      end
    end
  end
end