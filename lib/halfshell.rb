require 'halfshell/version'
require 'halfshell/terminal'
require 'halfshell/agent'

module Halfshell
  class Error < StandardError; end

  def Halfshell.<<(command)
    return ($hs = new) if :global == command
    new << command
  end

  def Halfshell.new
    Agent.new(terminal: Terminal.default)
  end

  def Halfshell.zsh
    Agent.new(terminal: Terminal.zsh)
  end
end

def hs
  Halfshell
end

alias :sh :hs
