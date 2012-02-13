module Rays
  class Backup
    attr_reader :directory, :number_of_backups, :stop_server

    def initialize(directory, number_of_backups, stop_server)
      @directory = directory
      @number_of_backups = number_of_backups # ignored for now
      @stop_server = stop_server # if server should be stopped before backup
      default
    end

    private
    def default
      @directory ||= '/tmp/rays_backup'
      @number_of_backups = 1
      @stop_server = false
    end
  end
end