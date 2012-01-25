require 'spec_helper'
require 'colorize'

describe 'solr adapter' do
  include Rays::SpecHelper

  before(:all) do
    recreate_test_project
    @skip = false
    if env.solr.nil? or !env.solr.alive?
      puts("\r\nskip solr tests because there is no alive solr server on the default port (8085)".yellow)
      @skip = true
    end
  end

  describe 'clean' do
    it 'should clean all records' do
      unless @skip
        add_test_data

        contains_test_data?.should be_true
        command.run(%w(solr clean))
        contains_test_data?.should be_false
      end
    end
  end

  private
  def contains_test_data?
    solr = env.solr.solr_instance
    response = solr.get('select', :params => {:q => 'uid:1', :limit => 1})
    !response.nil? and response['response']['numFound'] > 0
  end

  def add_test_data
    unless contains_test_data?
      solr = env.solr.solr_instance
      docs = [{:uid => 1, :content => 'test'}]
      solr.add docs
      solr.commit
    end
  end

  after(:all) do
    remove_test_project
  end
end