require 'halfshell/version'
require 'halfshell/terminal'
require 'halfshell/typist'

module Halfshell
  class Error < StandardError; end

  def Halfshell.new
    Typist.new(terminal: Terminal.default)
  end

  def Halfshell.<<(command)
    return ($hs = new) if :global == command
    new << command
  end
end

def hs
  Halfshell
end

alias :sh :hs
