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
  class Environment

    attr_reader :name

    def initialize(name, liferay, database, solr, backup)
      @name = name
      @liferay = liferay
      @database = database
      @solr = solr
      @backup = backup
    end

    def liferay
      raise RaysException.new('Liferay is not enabled for this project') if @liferay.nil?
      @liferay
    end

    def liferay_enabled?
      @liferay.nil?
    end

    def database
      raise RaysException.new('Database server is not enabled for this project') if @database.nil?
      @database
    end

    def database_enabled?
      @database.nil?
    end

    def solr
      raise RaysException.new('SOLR server is not enabled for this project') if @solr.nil?
      @solr
    end

    def solr_enabled?
      @solr.nil?
    end

    def backup
      raise RaysException.new('Backup is not enabled for this project') if @backup.nil?
      @backup
    end

    def backup_enabled?
      @backup.nil?
    end
  end
end