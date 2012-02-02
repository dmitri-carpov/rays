require 'spec_helper'

describe 'rays backup' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'all' do
    it 'should synchronize all from current environment to local' do
      pending
    end
  end

  describe 'database' do
    it 'should synchronize database from current environment to local' do
      pending
    end
  end

  describe 'data' do
    it 'should synchronize data from current environment to local' do
      pending
    end
  end
end