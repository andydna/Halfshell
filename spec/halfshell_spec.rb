require 'pry'

RSpec.describe HalfShell do
  let(:shell) { HalfShell.new }

  context 'OO subshells' do
    let(:expect_to_respond_to) do
      lambda { |mthd| expect(shell).to respond_to mthd }
    end

    context 'dead simple' do
      specify 'HalfShell << "ls spec/halfshell_spec.rb"' do
        expect(HalfShell << "ls spec/halfshell_spec.rb").to eq "spec/halfshell_spec.rb"
      end

      specify "hs === sh === HalfShell" do
        expect(hs << "ls")
        expect(sh << "ls")
      end
    end

    context 'principle of Least Suprise' do

      it '#stdin #stdout #stderr #pid' do
        [:stdin, :stdout, :stderr, :pid].each(&expect_to_respond_to)
      end

      it 'aliases #in #out #err' do
        [:in, :out, :err].each(&expect_to_respond_to)
      end

      it '#login?' do
        expect(shell.login?).to be false
      end

      it '#cd #pwd #cwd' do
        [:cd, :pwd, :cwd].each(&expect_to_respond_to)
      end

      it '#ls #ll' do
        [:ls, :ll,].each(&expect_to_respond_to)
      end

      it '#su' do
        [:su].each(&expect_to_respond_to)
      end

      it '#exit' do
        [:exit].each(&expect_to_respond_to)
      end
    end

    context 'dynamic messages mean arguments to commands' do

      it '#lsa = `ls -a`, #lsb, #lsc, ... #lsz' do
        ('a'..'z').map{|ltr|"ls#{ltr}".to_sym}.each(&expect_to_respond_to)
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
        skip "gotta figure out how to not hang"
        expect do
          shell << "mrowlatemymetalworm"
        end.to raise_error(AndyDNA::HalfShellError)
      end

      it 'is useful for testing my own programs' do
        skip
        expect(shell << "./hello").to match /there/
      end
    end
  end

  context "making it work for me" do
    it "STDIN, STDOUT, STDERR inspect well" do
      expect(shell.in.inspect).to match /STDIN/
    end

    context "forwarding" do
      it "puts should forward to @stdin" do
        expect(shell.stdin).to receive(:puts)
        shell.puts
      end

    #  it "gets should forward to @stdout" do
    #    expect(shell.stdout).to receive(:gets)
    #    shell.gets
    #  end

    end

    context "reading all the output without blocking" do
      it "whoami" do
        shell.puts "whoami"
        expect(shell.gets).to eq "andy\n"
      end

      fit "cowsay hi" do
        shell.puts "cowsay hi"
        #sleep 1 # lame but better than nothing
        expect(shell.gets).to eq "andy\n"
      end
    end

  end

  it "has a version number" do
    expect(HalfShell::VERSION).not_to be nil
  end

end
