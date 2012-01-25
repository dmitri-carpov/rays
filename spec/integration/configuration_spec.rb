require 'spec_helper'

describe 'rays build' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'project root' do
    it 'should get project root' do
      pending
    end

    it 'should fail on project root request if outside of a project' do
      pending
    end
  end

  describe 'environment' do
    it 'should get current environment' do
      pending
    end

    it 'should fail to get current environment if outside of a project root' do
      pending
    end

    it 'should fail to get current environment if environment.yml does not contain environment information' do
      pending
    end

    context 'base server on example of liferay' do
      context 'host' do
        it 'should get host information' do
          pending
        end

        it 'should fail if host information is missing' do
          pending
        end
      end

      context 'java home' do
        it 'should get java home information' do
          pending
        end

        it 'should fail if java home information is missing' do
          pending
        end
      end

      context 'java command' do
        it 'should get java command information' do
          pending
        end

        it 'should fail if java command information is missing' do
          pending
        end
      end
    end

    context 'remote service on example of liferay server' do
      context 'host' do
        it 'should get host information' do
          pending
        end

        it 'should fail if host information is missing' do
          pending
        end
      end

      context 'port' do
        it 'should get port information' do
          pending
        end

        it 'should fail if port information is missing' do
          pending
        end
      end

      context 'user' do
        it 'should get user information' do
          pending
        end

        it 'should fail if user information is missing' do
          pending
        end
      end
    end

    context 'liferay' do
      it 'should get liferay information' do
        pending
      end

      it 'should fail if liferay information is missing' do
        pending
      end

      context 'port' do
        it 'should get port information' do
          pending
        end

        it 'should fail if port information is missing' do
          pending
        end
      end

      context 'deploy directory' do
        it 'should get deploy directory information' do
          pending
        end

        it 'should fail if deploy directory information is missing' do
          pending
        end
      end
    end

    context 'database' do
      it 'should get database information' do
        pending
      end

      it 'should fail if database information is missing' do
        pending
      end
    end

    context 'solr' do
      it 'should get solr information' do
        pending
      end

      it 'should fail if solr information is missing' do
        pending
      end
    end

  end
end