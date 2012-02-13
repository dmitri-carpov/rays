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