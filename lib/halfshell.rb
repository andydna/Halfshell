require "open4"
require "forwardable"

module HalfShell
  SleepGenerator = Enumerator.new do |yielder|
    inc  = (3..).step
    fib = Hash.new{ |h,k| h[k] = k < 2 ? k : h[k-1] + h[k-2] } # https://stackoverflow.com/questions/6418524/fibonacci-one-liner
    loop {yielder << fib[inc.next]}
  end

  class Error < StandardError; end

  def HalfShell.new
    SH.new
  end

  def HalfShell.<<(command)
    new << command
  end

class SH
  extend Forwardable
  def_delegators :@stdin,  :puts

  def initialize
    @pid, @stdin, @stdout, @stderr = Open4::popen4 "sh"
    @try = 0
    @limit = 1000
    def_inspects
  end

  def <<(command)
    stdin.puts command
    gets
  end

  def gets_err
    return read_nonblock_loop(stderr)
  end

  def gets
    return read_nonblock_loop(stdout)
  end

  def read_nonblock_loop(io)
    got = ""
    loop do
      begin
        got << io.read_nonblock(1)
      rescue IO::EAGAINWaitReadable
        raise(Error, "no stdin") if (@try += 1) > @limit # should just return stderr; later
        if got.empty?
          sleep(1/(1000)) # gotta find a way, a better way
          return read_nonblock_loop(io)
        else
          return got
        end
      end
    end
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

  def cd(*args)
    stdin.puts "cd #{args.join(' ')}"
  end

  def pwd
    stdin.puts "pwd"
    gets
  end

  def cwd; end

  def ls(*args)
    stdin.puts "ls #{args.join(' ')}"
    gets
  end

  def ll(*args)
    stdin.puts "ls -l #{args.join(' ')}"
    gets
  end

  def lsh; end
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

  def def_inspects
    def stdin.inspect
      "#<STDIN:IO:fd #{fileno}>"
    end

    def stdout.inspect
      "#<STDOUT:IO:fd #{fileno}>"
    end

    def stderr.inspect
      "#<STDERR:IO:fd #{fileno}>"
    end
  end
end

end

def hs
  HalfShell
end
alias :sh :hs
