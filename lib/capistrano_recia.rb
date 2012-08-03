require 'capistrano'
require 'capistrano_telnet'
require 'capistrano_supports'
require 'nagios_mklivestatus'

load File.join(File.dirname(__FILE__), File.basename(__FILE__, ".rb"), "parents.rb")
load File.join(File.dirname(__FILE__), File.basename(__FILE__, ".rb"), "filter.rb")
load File.join(File.dirname(__FILE__), File.basename(__FILE__, ".rb"), "password.rb")

