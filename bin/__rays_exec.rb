#!/usr/bin/env ruby
require 'rays/interface/commander'

begin
  RaysCommand.run('rays', ARGV, {})
rescue => e
  # eat it.
end
