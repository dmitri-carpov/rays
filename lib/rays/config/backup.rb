module Rays
  class Backup
    attr_reader :directory, :number_of_backups, :stop_server

    def initialize(directory, number_of_backups, stop_server)
      @directory = directory
      @number_of_backups = number_of_backups
      @stop_server = stop_server
    end

    class << self
      def default
        new('/tmp/rays_backup', 1, false)
      end
    end
  end
end