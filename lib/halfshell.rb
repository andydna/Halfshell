require 'pry'
require 'halfshell/version'
require 'halfshell/fibonacci_generator'
require 'halfshell/terminal'
require "open4"

module Halfshell
  WAIT = 1.0/10000

  class Error < StandardError; end

  def Halfshell.new
    Typist.new(terminal: Terminal.default)
  end

  def Halfshell.<<(command)
    new << command
  end

class Typist
  def initialize(terminal:, backoff: FibonacciEnumerator.from(3))
    @terminal = terminal;
    # def_inspects

    @try = 0
    @limit = 20
    @backoff = backoff
  end

  def type(*what)
    @terminal.puts(*what)
    self
  end

  def <<(command)
    @terminal.puts command
    gets
  end

  def gets_err
    return read_nonblock_loop(@terminal.err)
  end

  def gets
    @terminal.gets
    #return read_nonblock_loop(@terminal.out)
  end
  alias :gets_in :gets

  def login?
    @terminal.puts "echo $0"
    @terminal.gets[0] == "-"
  end

  def cd(*args)
    @terminal.puts "cd #{args.join(' ')}"
  end

  # actual commands
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
    "#<#Typist:#{object_id}>"
  end

  def method_missing(mthd, *args, &block)
    super(mthd, *args, &block)
  end

  def respond_to_missing?(mthd, include_private = false) # DO NOT USE THIS DIRECTLY.
    mthd.to_s.match? /ls|tar|ps/ || super
  end

  def twiddle_thumbs
    sleep(WAIT*@backoff.next)
  end

  private

  # belongs on terminal
#  def def_inspects
#    %w[in out err].each do |io|
#      send(io.to_sym).define_singleton_method(:inspect) do
#        "#<#{io.upcase}:IO:fd #{fileno}>"
#      end
#    end
#  end

end

end

def hs
  Halfshell
end
alias :sh :hs
