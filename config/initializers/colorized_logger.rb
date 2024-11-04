# frozen_string_literal: true

# Adapted from: https://gist.github.com/kyrylo/3d90f7a656d1a0accf244b8f1d25999b
module ColorizedLogger
  COLORS = {
    debug: "\e[0;36m", # Cyan
    info:  "\e[0;32m", # Green
    warn:  "\e[0;33m", # Yellow
    error: "\e[0;31m", # Red
    fatal: "\e[1;31m", # Bold Red
    unknown: "\e[0m" # Terminal default
  }.freeze

  RESET = "\e[0m"

  COLORS.each_key do |level|
    define_method(level) do |progname = nil, &block|
      message = progname || (block && block.call)
      super("#{COLORS[level]}#{message}#{RESET}")
    end
  end
end

Rails.logger.extend(ColorizedLogger)
