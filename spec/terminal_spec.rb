require 'spec_helper'

$testing = true

RSpec.describe Halfshell::Terminal do
  let(:default) { Halfshell::Terminal.default }

  context "interface" do
    it "#puts and #gets are Ruby-ishly obvious" do
      expect(default).to respond_to :puts
      expect(default).to respond_to :gets
    end
  end

  context "sensible Terminal.default" do
    it "needs no args" do
      expect(Halfshell::Terminal.default)
    end

    it "returns open4 using /bin/sh by default" do
      open4 = spy
      stub_const('Open4', open4)
      expect(open4).to receive(:popen4).with(/sh/)
      Halfshell::Terminal.default
    end

    it "should 2>&1" do
      default.puts "ls /"
      expect(default.gets).to match /usr/
      default.puts "asdfasdfasdf"
      expect(default.gets).to match /command not found/
    end

    it "stderr should also be readable alone" do
      skip "i don't know how to do this yet.  wanna tee stderr to 1: back to itself 2: stderr"
      default.puts "asdfasdfasdf"
      expect(default.gets).to match /command not found/
      expect(default.gets_err).to match /command not found/
    end
  end

  context "interactive programs" do
    it "su" do
      default.puts "su"
      expect(default.gets).to match /Password|Sorry/
    end
  end

  context "raise_error binding.pry if $testing" do
    skip "i don't know how to test this yet"
  end

  context "i need a zsh so i can map `where mybin.next` and figure out how i fucked up make/awk" do
    it "exists" do
      zsh = Halfshell::Terminal.zsh
      expect(zsh)

      zsh.puts "where ls"
      expect(zsh.gets).not_to match /line 1: where: command not found/
    end
  end
end
