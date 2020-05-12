require "halfshell/version"

require "open4"
require "forwardable"

module HalfShell

  class Error < StandardError; end

  def HalfShell.new
    SH.new
  end

  def HalfShell.<<(command)
    new << command
  end

class SH
  extend Forwardable
  def_delegators :@stdout, :puts
  def_delegators :@stdin, :gets

  def initialize
    @pid, @stdin, @stdout, @stderr = Open4::popen4 "sh"
    def_inspects
  end

  def <<(command)
    stdin.puts command
    first_line
  end

  def pid
    @pid
  end

  def stdin
    @stdin
  end
  alias :in :stdin

  def stdout
    @stdout
  end
  alias :out :stdout

  def stderr
    @stderr
  end
  alias :err :stderr

  def login?
    stdin.puts "echo $0"
    stdout.gets[0] == "-"
  end

  def cd; end
  def pwd
    stdin.puts "pwd"
    first_line
  end
  def cwd; end

  def ls(*args)
    stdin.puts "ls #{args.join(' ')}"
    first_line
  end

  def ll; end
  def lsh; end

  def clear; end

  def su; end

  def clear; end

  def exit; end

  def method_missing(mthd, *args, &block)
    super(mthd, *args, &block)
  end

  def respond_to_missing?(mthd, include_private = false) # DO NOT USE THIS DIRECTLY.
    mthd.to_s.match? /ls|tar|ps/ || super
  end

  private

  def first_line
    stdout.each_line.take(1).join.strip #shitty
  end

  def two_lines
    stdout.each_line.take(2).join # shitty
  end

  def def_inspects
    # wanna each define_singleton_method.
    # but how to => expect(@ivar.to_s).to eq('ivar')
    def @stdin.inspect
      "<STDIN:IO:fd #{fileno}>"
    end

    def @stdout.inspect
      "<STDOUT:IO:fd #{fileno}>"
    end

    def @stderr.inspect
      "<STDERR:IO:fd #{fileno}>"
    end
  end
end

end

def hs
  HalfShell
end
alias :sh :hs
