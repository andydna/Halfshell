module Halfshell
  class Terminal

    def Terminal.default
      Terminal.popen4
    end

    OPEN4_RETURNS = [:pid, :stdin, :stdout, :stderr]

    def Terminal.popen4
      Terminal.new(**OPEN4_RETURNS.zip(Open4::popen4("sh 2>&1")).to_h)
    end

    def initialize(stdin:, stdout:, stderr:, pid:)
      @stdin, @stdout, @stderr, @pid = stdin, stdout, stderr, pid

      @try = 0
      @limit = 1000
    end

    def puts(what)
      @stdin.puts what
    end

    def gets
      read_nonblock_loop(@stdout)
    end

    def read_nonblock_loop(io)
      got = ""
      loop do
        begin
          got << io.read_nonblock(1)
        rescue IO::EAGAINWaitReadable
          raise_error if too_many_tries?
          if got.empty?
            sleep(1.0/1000) #sleep(WAIT*@backoff.next)
            return read_nonblock_loop(io)
          else
            @try = 0
            return got
          end
        end
      end
    end

    def too_many_tries?
      @try >= @limit
    end

    def raise_error
      binding.pry
      raise Error
    end
  end
end
