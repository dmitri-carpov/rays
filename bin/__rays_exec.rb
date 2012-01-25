#!/usr/bin/env ruby
require 'rays/interface/commander'

begin
  RaysCommand.run("", ARGV, {})
rescue => e
  # eat it.
end
