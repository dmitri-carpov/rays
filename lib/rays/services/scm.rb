#
# DO NOT SUPPORT FOR NOW
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