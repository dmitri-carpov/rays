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

$log = Logger.new(STDOUT)
$log.level = Logger::INFO
$log.formatter = proc do |severity, datetime, progname, msg|
  color = lambda do |message, color|
    open_tag = '<!'
    close_tag = '!>'
    colored_message = ''
    message.split(open_tag).each do |sub_message|
      if sub_message.include?(close_tag)
        sub_messages = sub_message.split(close_tag)
        colored_message << sub_messages.first
        colored_message << sub_messages.last.colorize(color)
      else
        colored_message << sub_message.colorize(color)
      end
    end
    colored_message
  end
  message = "#{msg}\n"
  message = color.call(message, :green) if severity.eql? 'INFO'
  message = color.call(message, :red) if severity.eql? 'ERROR'
  message = color.call(message, :yellow) if severity.eql? 'WARN'
  message = message if severity.eql? 'DEBUG'
  message
end

def $log.debug_on
  $log.level = Logger::DEBUG
end

def $log.silent_on
  $log.level = Logger::FATAL
end

def $log.reset
  $log.level = Logger::INFO
end
