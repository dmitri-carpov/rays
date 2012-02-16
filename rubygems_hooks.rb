registered = false

bashrc = "#{ENV['HOME']}/.bashrc"
bashrc = "#{ENV['HOME']}/.bash_profile" unless File.exists?(bashrc)

begin
  registered = !open(bashrc).grep(/rays/).empty?
rescue => e
  # do nothing
end

unless registered

  config_dir = '.rays_config'
  config_path = "#{ENV['HOME']}/#{config_dir}"

  # Create directory and copy template
  unless Dir.exists?(config_path)
    require 'fileutils'
    require 'find'
    FileUtils.mkdir(config_path)
    template_path = "#{File.expand_path(File.dirname(__FILE__))}/lib/rays/config/templates/global"
    Find.find(template_path) do |file|
      file_base_path = file.sub(template_path, "")
      next if file_base_path.empty?
      FileUtils.cp_r(file, File.join(config_path, file_base_path))
    end
  end

  script_file = "$HOME/#{config_dir}/scripts/rays"
  command = "\n[[ -s \"#{script_file}\" ]] && source \"#{script_file}\" # Load RAYS into a shell session *as a function*'\n\n"
  File.open(bashrc, 'a') do |file|
    file.write(command)
  end
end