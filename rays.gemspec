Gem::Specification.new do |s|
  s.name        = 'rays'
  s.version     = '0.1.0'
  s.summary     = 'SFL Liferay developer tool'
  s.description = 'Command line tool to create and manage liferay projects'

  s.author      = 'Dmitri Carpov'
  s.email       = 'dmitri.carpov@gmail.com'
  s.homepage    = 'http://projects.savoirfairelinux.net/projects/rays'

  s.add_dependency('clamp')
  s.add_dependency('rsolr')
  s.add_dependency('colorize')
  s.add_dependency('net-ssh')
  s.add_dependency('highline')
  s.add_dependency('safe_shell')
  s.add_dependency('nokogiri')

  s.files       = Dir['lib/**/*', 'lib/rays/config/templates/project/.rays', 'rubygems_hooks.rb']
  s.executables << '__rays_exec.rb'
  s.post_install_message = lambda {
    require('./rubygems_hooks.rb')
    require('colorize')
    return "registered rays function in your bash profile\nplease reopen your shell window".green
  }.call # awful way to do it, until a proper way to set gem hooks is found
end


