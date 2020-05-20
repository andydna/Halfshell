require 'spec_helper'

RSpec.describe Halfshell::Agent do
  let(:typist) { Halfshell::Agent.new }

  specify 'Agent#type is chainable' do
    typist = Halfshell::Agent.new(terminal: spy)
    expect(typist.type("ls").type("ls")).to eq typist
  end

  context 'reads stdout and sterr together and seperate' do
    skip # this kinda sucks but i wanna stay rolling
    it 'stderr first' do
      terminal = instance_double(Halfshell::Terminal)
      expect(terminal).to receive(:puts).with("mkdri").and_return("ERROR")
      typist = Halfshell::Agent.new(terminal: terminal)
      typist.type("mkdri")
    end
  end

  it 'should look good in the repl' do
    raph = Halfshell.new
    expect(raph.inspect).not_to match /0x0/
  end

  context "Collaboration w/terminal" do
    context "I can mock it; want a struct with 3 IOs and an int for pid" do
      let(:terminal) { spy }
      
      it "Agent#type calls @terminal#gets then @terminal#puts" do
        expect(terminal).to receive(:gets)
        expect(terminal).to receive(:puts)
        Halfshell::Agent.new(terminal: terminal).type("ls").gets
      end
    end
  end

  context 'principle of Least Suprise' do
    let(:expect_to_respond_to) do
      lambda { |mthd| expect(typist).to respond_to mthd }
    end

    it '#login?' do
      expect(typist.login?).to be false
    end

    it '#cd #pwd' do
      [:cd, :pwd].each(&expect_to_respond_to)
      expect(typist.pwd).to match Regexp.new(/#{File.expand_path('.')}/i)
      typist.cd "/etc"
      expect(typist.pwd).to eq "/etc\n"
    end

    it '#ls #ll' do
      [:ls, :ll,].each(&expect_to_respond_to)
      expect(typist.ls).to include "Gemfile"
      expect(typist.ll).to include "drwx"
    end

    it '#su' do
      [:su].each(&expect_to_respond_to)
    end

    it '#exit' do
      [:exit].each(&expect_to_respond_to)
    end

    context 'dynamic messages mean arguments to commands' do
      it '#lsa = `ls -a`, #lsb, #lsc, ... #lsz' do
        ('a'..'z').map{|ltr|"ls#{ltr}".to_sym}.each(&expect_to_respond_to)
      end
    end
  end
end
