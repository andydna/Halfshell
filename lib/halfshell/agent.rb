module Halfshell

class Agent
  def initialize(terminal: Terminal.default)
    @terminal = terminal;

    @try = 0
    @limit = 20
  end

  def type(*what)
    @terminal.puts(*what)
    self
  end

  def <<(command)
    @terminal.puts command
    gets
  end

  def gets
    @terminal.gets
  end

  def login?
    @terminal.puts "echo $0"
    @terminal.gets[0] == "-"
  end

  def cd(*args)
    @terminal.puts "cd #{args.join(' ')}"
  end

  def pwd
    self.<< "pwd"
  end

  def ls(*args)
    self.<< "ls #{args.join(' ')}"
  end

  def ll(*args)
    self.<< "ls -l #{args.join(' ')}"
  end

  def lsh; end
  def su; end
  def clear; end
  def exit; end

  alias :old_inspect :inspect
  def inspect
    "#<#{self.class}:#{object_id}>"
  end

  def method_missing(mthd, *args, &block)
    super(mthd, *args, &block)
  end

  def respond_to_missing?(mthd, include_private = false) # DO NOT USE THIS DIRECTLY.
    mthd.to_s.match? /ls|tar|ps/ || super
  end
end

end
