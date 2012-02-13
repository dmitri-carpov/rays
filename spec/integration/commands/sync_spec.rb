require 'spec_helper'

describe 'rays backup' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'sync' do
    it 'should synchronize current environment to local' do
      pending
    end
  end
end