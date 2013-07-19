require "active_support"

class SelectiveLogger < ActiveSupport::BufferedLogger

  attr_accessor :silent

  def initialize path_to_log_file
    super path_to_log_file
  end

  def add severity, message = nil, progname = nil, &block
    super unless @silent
  end
end
