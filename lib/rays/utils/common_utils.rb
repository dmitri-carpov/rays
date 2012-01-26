#
# 1. Execution pointcuts
# 2. General use methods
#

# 1. Execution pointcuts

#
# Execute a given block and process any exception with a proper logging.
#
def log_block(message)
  begin
    yield
  rescue RaysException => e
    $log.error(e)
    $log.debug("#{e}:\tBacktrace:\r\n#{e.backtrace.join("\r\n")}")
    raise e
  rescue => e
    $log.error("Cannot #{message}.")
    $log.debug("#{e}:\tBacktrace:\r\n#{e.backtrace.join("\r\n")}")
    raise e
  end
end

#
# Wrap a given block with progress information.
#
def task(start_message, done_message, failed_message)
  begin
    $log.info(start_message)
    yield
    $log.info(done_message)
  rescue => e
    $log.error("#{failed_message}\nreason: #{e.message}")
    $log.debug("#{e}.:\tBacktrace:\r\n#{e.backtrace.join("\r\n")}")
    raise e
  end
end

#
# Block console output for a given block.
#
def silent
  begin
    orig_stdout = $stdout.dup # does a dup2() internally
    $stdout.reopen('/dev/null', 'w')
    yield
  ensure
    $stdout.reopen(orig_stdout)
  end
end


# 2. General use methods

#
# Execute OS command.
#
def rays_exec(command)
  success = false
  if $log.debug?
    success = system command
  else
    silent { success = system command }
  end
  raise RaysException.new("Failed to execute: #{command}") unless success
  success
end

#
# Safe execute. Use it for user input commands.
#
def rays_safe_exec(command, *args)
  SafeShell.execute(command, *args)
end

#
# Execute a given code a directory.
#
def in_directory(directory)
  original_directory = Dir.pwd
  Dir.chdir(directory) if Dir.exist?(directory)
  begin
    yield
  ensure
    Dir.chdir(original_directory)
  end
end

#
# Create a missing option string
#
def missing_environment_option(name, option)
  "#{name} does not contain #{option} information. see config/environment.yml"
end

#
# Check if command in the PATH
#
def command?(command)
  system("which #{ command} > /dev/null 2>&1")
end

