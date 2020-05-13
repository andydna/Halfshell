module Halfshell
  Terminal = Struct.new(:in, :out, :err, :pid, keyword_init: true)
end
