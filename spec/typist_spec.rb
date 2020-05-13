require 'spec_helper'

RSpec.describe Halfshell::Typist do
  fspecify 'Typist#type returns self' do
    typist = Halfshell::Typist.new(terminal: spy)
    expect(typist.type("ls").type("ls")).to eq typist
  end

  # can probably tell the difference between stderr and stdout
  # but sees them all together
  
  context 'reads stdout and sterr together and seperate' do
    fit 'stderr first' do
      terminal = class_double(Halfshell::Terminal)
      expect(terminal).to receive("mkdri").and_return("ERROR")
    end
  end
end
