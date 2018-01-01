require 'logger'

module Kernel
    @@logger = Logger.new(STDOUT)
    @@util_verbosity = true

    def util_verbosity=(v)
        @@util_verbosity = v
    end

    def util_verbosity
        @@util_verbosity
    end

    def logger
        @@logger
    end

    def log message
        @@logger.info message
    end

    def error message
        @@logger.error message
    end

    def debug message
        @@logger.debug message
    end
end

###
# Makes a module you can include with `include Logging`
###
# module Logging
#   class << self
#     def logger
#       @logger ||= Logger.new($stdout)
#     end

#     def logger=(logger)
#       @logger = logger
#     end
#   end

#   # Addition
#   def self.included(base)
#     class << base
#       def logger
#         Logging.logger
#       end
#     end
#   end

#   def logger
#     Logging.logger
#   end
# end