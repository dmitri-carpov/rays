exit 1 unless system('bundle check')

require 'rspec/core/rake_task'
require 'colorize'

task :gem => [:spec] do
  system "gem build rays.gemspec"
  system "gem install raystool-1.0.0.gem"
end

if ARGV.include?('--no-spec')
  task :spec do
    puts("Warning: tests are skipped".red)
  end
else
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = ['--color']
  end
end
