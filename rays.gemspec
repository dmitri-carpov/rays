require('colorize')

Gem::Specification.new do |s|
  s.name        = 'raystool'
  s.version     = '1.0.3'
  s.summary     = 'Liferay developer tool'
  s.description = 'Command line tool to create and manage liferay projects'

  s.author      = 'Dmitri Carpov'
  s.email       = 'dmitri.carpov@gmail.com'
  s.homepage    = 'https://github.com/dmitri-carpov/rays'

  s.add_dependency('clamp')
  s.add_dependency('rsolr')
  s.add_dependency('colorize')
  s.add_dependency('net-ssh')
  s.add_dependency('highline')
  s.add_dependency('safe_shell')
  s.add_dependency('nokogiri')

  s.files       = Dir['lib/**/*', 'lib/rays/config/templates/project/.rays', 'rubygems_hooks.rb']
  s.executables << '__rays_exec.rb'
  s.executables << '__rays_init'
  s.post_install_message = "Please run '__rays_init' after installation".red
end


