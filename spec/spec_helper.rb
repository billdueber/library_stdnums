# minitest has a circular reference somewhere
# drives me crazy
def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE   = nil
  result     = block.call
  $VERBOSE   = warn_level
  result
end


silence_warnings do
  require 'minitest/spec'
  require 'minitest/autorun'
end


require 'library_stdnums'

