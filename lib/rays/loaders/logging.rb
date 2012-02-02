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
