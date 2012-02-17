=begin
Copyright (c) 2012 Dmitri Carpov

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
=end

module Rays
  module Server

    class SolrServer < BaseServer
      attr_reader :solr_instance

      def initialize(name, host, remote, java_home, java_bin, port, url, application_service)
        super(name, host, remote, java_home, java_bin)
        @port = port
        @url = url
        @solr_instance = RSolr.connect(:url => solr_url)
        @service = application_service
      end

      def port
        raise RaysException.new(missing_environment_option('SOLR server', 'port')) if @port.nil?
        @port
      end

      def url
        raise RaysException.new(missing_environment_option('SOLR server', 'instance')) if @url.nil?
        @url
      end

      def service
        raise RaysException.new(missing_environment_option('SOLR service', 'service')) if @service.nil?
        @service
      end

      def alive?
        begin
          @solr_instance.get('select', :params => { :q => '*:*', :limit => 1})
          return true
        rescue
          return false
        end
      end

      def clean_all
        solr_transaction do
          @solr_instance.delete_by_query('*:*')
        end
      end

      private
      def solr_transaction
        $log.info("Connecting to the solr server ...")
        unless alive?
          $log.error("Cannot connect to the solr server.")
          return
        end
        begin
          log_block("execute solr query") do
            yield
            @solr_instance.commit
          end
        rescue Errno::ECONNREFUSED => e
          rollback
          $log.error("Cannot connect to the solr server. URL: " + solr_url)
          $log.debug("Cause: #{e.message}.\tBacktrace:\r\n#{e.backtrace.join("\r\n")}")
        rescue RSolr::Error::Http => e
          rollback
          $log.error("Bad solr request. URL: " + solr_url)
          $log.debug("Cause: #{e.message}.\tBacktrace:\r\n#{e.backtrace.join("\r\n")}")
        rescue => e
          rollback
          $log.error("Unknown solr error.")
          $log.debug("Cause: #{e.message}.\tBacktrace:\r\n#{e.backtrace.join("\r\n")}")
        end
      end

      def solr_url
        url_string = "http://#{host}"
        url_string << ":#{port}"
        url_string << "/#{url}"
        url_string
      end

      def rollback
        begin
          @solr_instance.rollback
        rescue
          # stub
        end
      end
    end
  end
end