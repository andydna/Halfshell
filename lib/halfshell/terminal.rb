require "open4"
require "expect"

module Halfshell
  class Terminal
    TIMEOUT       = 60 * 60
    WAIT_INTERVAL = 1.0/1000

    def Terminal.default
      Terminal.sh
    end

    def Terminal.zsh
      Terminal.new(**OPEN4_RETURNS.zip(Open4::popen4("zsh 2>&1")).to_h)
    end

    OPEN4_RETURNS = [:pid, :stdin, :stdout, :stderr]

    def Terminal.sh
      Terminal.new(**OPEN4_RETURNS.zip(Open4::popen4("sh 2>&1")).to_h)
    end

    def initialize(stdin:, stdout:, stderr:, pid:)
      @stdin, @stdout, @stderr, @pid = stdin, stdout, stderr, pid

      @tries = 0
      @max_tries = (TIMEOUT / WAIT_INTERVAL).to_i
    end

    def puts(what)
      @stdin.puts what
    end

    def gets
      read_nonblock_loop(@stdout)
    end

    def gets_err
      read_nonblock_loop(@stderr)
    end

    def read_nonblock_loop(io)
      got = ""
      loop do
        begin
          got << io.read_nonblock(1)
        rescue IO::EAGAINWaitReadable
          raise_error if too_many_tries?
          if got.empty?
            sleep(WAIT_INTERVAL)
            return read_nonblock_loop(io)
          else
            @tries = 0
            return got
          end
        end
      end
    end

    def too_many_tries?
      @tries >= @max_tries
    end

    def raise_error
      binding.pry if $testing
      raise Error
    end
  end
end
