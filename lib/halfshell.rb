require 'halfshell/version'
require "open4"

module HalfShell
  OPEN4_RETURNS = [:pid, :stdin, :stdout, :stderr]
  WAIT = 1/1000

  class Error < StandardError; end

  def HalfShell.new
    SH.new(slave: SubShell.new(**OPEN4_RETURNS.zip(Open4::popen4("sh")).to_h))
  end

  def HalfShell.<<(command)
    new << command
  end

  SubShell = Struct.new(:stdin, :stdout, :stderr, :pid, keyword_init: true)

class SH
  def initialize(slave:, backoff: FibonacciEnumerator.from(3))
    @slave = slave;
    def_inspects

    @try = 0
    @limit = 1000
    @backoff = backoff
  end

  attr_reader :pid, :stdin, :stdout, :stderr
  alias :in :stdin
  alias :out :stdout
  alias :err :stderr

  def puts(*what)
    @slave.stdin.puts(*what)
  end

  def <<(command)
    @slave.stdin.puts command
    gets
  end

  def gets_err
    return read_nonblock_loop(@slave.stderr)
  end

  def gets
    return read_nonblock_loop(@slave.stdout)
  end
  alias :gets_in :gets

  def login?
    @slave.stdin.puts "echo $0"
    @slave.stdout.gets[0] == "-"
  end

  def cd(*args)
    @slave.stdin.puts "cd #{args.join(' ')}"
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
    "#<#SH:#{object_id}>"
  end

  def method_missing(mthd, *args, &block)
    super(mthd, *args, &block)
  end

  def respond_to_missing?(mthd, include_private = false) # DO NOT USE THIS DIRECTLY.
    mthd.to_s.match? /ls|tar|ps/ || super
  end

  private

  def def_inspects
    %w[stdin stdout stderr].each do |io|
      send(io.to_sym).define_singleton_method(:inspect) do
        "#<#{io.upcase}:IO:fd #{fileno}>"
      end
    end
  end

  def read_nonblock_loop(io)
    got = ""
    loop do
      begin
        got << io.read_nonblock(1)
      rescue IO::EAGAINWaitReadable
        raise(Error, "no stdin") if (@try += 1) > @limit # should just return stderr; later
        if got.empty?
          sleep(WAIT*@backoff.next)
          return read_nonblock_loop(io)
        else
          @try = 0
          return got
        end
      end
    end
  end
end

end

def hs
  HalfShell
end
alias :sh :hs
