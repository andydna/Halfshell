module Halfshell
  OPEN4_RETURNS = [:pid, :in, :out, :err]
  Terminal = Struct.new(:in, :out, :err, :pid, keyword_init: true)
end
