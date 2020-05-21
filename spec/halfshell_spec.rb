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

    context "doesn't hang on which" do
      context "when which $DOES_EXIST" do
        it 'Halfshell << "which ls"' do
          expect(Halfshell << "which ls").to match /bin\/ls/
        end

        it 'Halfshell.new << "which ls"' do
          expect(Halfshell.new << "which ls").to match /bin\/ls/
        end

        it 'Halfshell.zsh << "which ls"' do
          expect(Halfshell.zsh << "which ls").to match /bin\/ls/
        end
      end

      context "when which $DOES_NOT_EXIST" do
        fit "#<<" do
          expect(Halfshell << "which asdfasdfasdf").to match /foo/
        end
      end
    end
  end
end
