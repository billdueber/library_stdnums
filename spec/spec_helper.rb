require 'rubygems'
require 'bacon'
begin
  require 'greeneggs'
rescue LoadError
end
$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'library_stdnums'

Bacon.summary_on_exit
