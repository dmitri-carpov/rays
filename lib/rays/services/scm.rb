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

#
# NOT SUPPORTED
#
module Rays

  class SCM
    def initialize(path, username, password, type)
      raise RaysException "unknown SCM type." if type.nil?
      if type.eql? "svn"
        @instance = SVN.new path, username, password, $rays_config.project_root
      else
        @instance = Git.new path, Rays::Utils::FileUtils.project_root
      end
    end

    def update
      @instance.update
    end

    def checkout
      @instance.checkout
    end

    def clean_checkout
      @instance.checkout "/tmp/#{Project.instance.name}"
    end

  end

  private

  class Git
    def initialize path, source_dir
      @path = path
      @source_dir = source_dir
    end

    def checkout dir = nil
      dir ||= @source_dir
      rays_exec "git clone #{@path} #{dir}"
      @source_dir = dir
    end

    def update
      in_directory(@source_dir) do
        rays_exec "git pull origin"
      end
    end
  end

  class SVN
    def initialize path, username, password, source_dir
      @path = path
      @username = username
      @password = password
      @source_dir = source_dir
    end

    def checkout(dir = nil)
      dir ||= @source_dir
      rays_exec("svn co #{@path} --username=#{@username} --password=#{@password} #{dir}")
      @source_dir = dir
    end

    def update
      system_exec("cd #{@source_dir} && svn up", $rays_config.debug)
    end
  end
end