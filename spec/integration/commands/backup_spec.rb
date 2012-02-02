require 'spec_helper'

describe 'rays backup' do
  include Rays::SpecHelper

  before(:each) do
    recreate_test_project
  end

  describe 'all' do
    it 'should backup all to backup folder' do
      pending
    end
  end

  describe 'database' do
    it 'should backup database to backup folder' do
      pending
    end
  end

  describe 'data' do
    it 'should backup data to backup folder' do
      pending
    end
  end

  describe 'settings' do
    it 'should respect number of backups to keep' do
      pending
    end
  end
end