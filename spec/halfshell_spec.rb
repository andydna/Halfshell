require 'pry'

RSpec.describe HalfShell do
  let(:shell) { HalfShell.new }

  context 'OO subshells' do
    context 'dead simple' do
      specify 'HalfShell << "ls spec/halfshell_spec.rb"' do
        expect(HalfShell << "ls spec/halfshell_spec.rb").to eq "spec/halfshell_spec.rb\n"
      end

      specify "hs === sh === HalfShell" do
        expect(hs << "ls /").to match /bin/
        expect(sh << "ls /").to match /bin/
        expect(HalfShell << "ls /").to match /bin/
      end
    end

    context 'principle of Least Suprise' do
      let(:expect_to_respond_to) do
        lambda { |mthd| expect(shell).to respond_to mthd }
      end

      it '#stdin #stdout #stderr #pid' do
        [:stdin, :stdout, :stderr, :pid].each(&expect_to_respond_to)
      end

      it 'aliases #in #out #err' do
        [:in, :out, :err].each(&expect_to_respond_to)
      end

      it '#login?' do
        expect(shell.login?).to be false
      end

      it '#cd #pwd' do
        [:cd, :pwd, :cwd].each(&expect_to_respond_to)
        expect(shell.pwd).to match Regexp.new(/#{File.expand_path('.')}/i)
        shell.cd "/etc"
        expect(shell.pwd).to eq "/etc\n"
      end

      it '#ls #ll' do
        [:ls, :ll,].each(&expect_to_respond_to)
        expect(shell.ls).to include "Gemfile"
        expect(shell.ll).to include "drwx"
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

    context 'wire up open4' do
      it 'pwd' do
        expect(shell.pwd).to match /#{File.expand_path(Dir.pwd)}/i
      end

      it 'shovel in arbitrary commands' do
        expect(shell << "which sh").to match Regexp.new("/bin/sh")
      end

      it 'what about garbage commands' do
        expect do
          shell << "mrowlatemymetalworm"
        end.to raise_error(HalfShell::Error)
      end
    end
  end

  context "reading standard error" do
  end

  context "making it work for me" do
    it "STDIN, STDOUT, STDERR inspect well" do
      expect(shell.in.inspect).to match /STDIN/
    end

    it "#puts forwards to @stdin" do
      expect(shell.stdin).to receive(:puts)
      shell.puts
    end

    it "#gets reads without blocking" do
      shell.puts "cowsay hi"
      expect(shell.gets).to match /< hi >/
    end
  end
end
