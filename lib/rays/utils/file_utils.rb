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
  module Utils
    module FileUtils
      #
      # Get parent path from a given path
      #
      def self.parent dir
        return nil unless Dir.exists?(dir)
        Pathname.new(dir).parent.to_s
      end

      #
      # Find a file specified by regexp in a given directory recursively down.
      #
      def self.find_down dir, file
        files = []
        if Dir.exist?(dir)
          Find.find(dir) do |file_path|
            next unless file_path.match(file)
            files << file_path
          end
        end
        files
      end

      #
      # Find a parent directory which contains a given file name (no patterns allowed)
      #
      def self.find_up file, dir = Dir.pwd, limit = '/'
        return nil if dir.eql? limit or !dir.start_with?(limit)
        return dir unless Dir.new(dir).find_index(file).nil?
        find_up file, Pathname.new(dir).parent.to_s, limit
      end

      #
      # Get list of child directory names of a given directory.
      # Goes one level down only.
      #
      def self.find_directories path, hidden=false
        dirs = []
        Dir.glob("#{path}/*/").each do |dir|
          dirs << File.basename(dir)
        end
        if hidden
          Dir.glob("#{path}/.*/").each do |dir|
            basename = File.basename(dir)
            dirs << File.basename(dir) if basename != '.' and basename != '..'
          end
        end
        dirs
      end

      #
      # YamlFile allows to work with java .properties files as a ruby hash
      #
      class YamlFile
        attr_reader :properties

        def initialize(file)
          @file_name = file
          @properties = {}
          @properties = YAML::load_file(File.open(@file_name)) || Hash.new
        end

        def write
          File.open(@file_name, 'w') do |out|
            YAML.dump(@properties, out)
          end
        end
      end

      #
      # PropertiesFile allows to work with java .properties files as a ruby hash
      #
      class PropertiesFile
        attr_reader :properties

        def initialize file
          @file_name = file
          @properties = {}
          file = File.open(@file_name, 'r')
          IO.foreach(file) do |line|
            @properties[$1.strip] = $2 if line =~ /([^=]*)=(.*)\/\/(.*)/ || line =~ /([^=]*)=(.*)/
          end
        end

        def write
          properties_file = File.new(@file_name, 'w+')
          @properties.each { |key, value| properties_file.puts "#{key}=#{value}\n" }
          properties_file.close
        end
      end
    end
  end
end