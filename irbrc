require 'rubygems'
begin
   require 'wirble'
   #start wirble (with color)
   Wirble.init
   Wirble.colorize
rescue LoadError => err
  warn "Couldn't load Wirble: #{err}"
end
require 'irb/completion'
require 'irb/ext/save-history'

IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:PROMPT_MODE]  = :SIMPLE

# Just for Rails...
#if rails_env = ENV['RAILS_ENV']
#  rails_root = File.basename(Dir.pwd)
#  IRB.conf[:PROMPT] ||= {}
#  IRB.conf[:PROMPT][:RAILS] = {
#    :PROMPT_I => "#{rails_root}> ",
#    :PROMPT_S => "#{rails_root}* ",
#    :PROMPT_C => "#{rails_root}? ",
#    :RETURN   => "=> %s\n" 
#  }
#  IRB.conf[:PROMPT_MODE] = :RAILS

  # Called after the irb session is initialized and Rails has
  # been loaded (props: Mike Clark).
  #  IRB.conf[:IRB_RC] = Proc.new do
  #    ActiveRecord::Base.logger = Logger.new(STDOUT)
  #    ActiveRecord::Base.instance_eval { alias :[] :find }
  #  end
#end

