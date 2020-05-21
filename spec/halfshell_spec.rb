require "pry"

RSpec.describe Halfshell do
  let(:half_shell) { Halfshell.new }

  context 'dead simple' do
    specify 'Halfshell << "ls spec/halfshell_spec.rb"' do
      expect(Halfshell << "ls spec/halfshell_spec.rb").to eq "spec/halfshell_spec.rb\n"
    end

    specify "hs === sh === Halfshell" do
      expect(hs << "ls /").to match /bin/
      expect(sh << "ls /").to match /bin/
      expect(Halfshell << "ls /").to match /bin/
    end

    it "maybe you want a single global $sh" do
      Halfshell << :global
      expect($hs << 'pwd').to match /#{Dir.pwd}/
    end

    it "can return a zsh" do
      zsh = Halfshell.zsh
      expect(zsh.puts("echo $0").gets).to match /zsh/
    end
  end
end
