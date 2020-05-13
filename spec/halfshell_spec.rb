require 'pry'

RSpec.describe Halfshell do
  let(:half_shell) { Halfshell.new }

  context 'OO subshells' do
    context 'dead simple' do
      specify 'Halfshell << "ls spec/halfshell_spec.rb"' do
        expect(Halfshell << "ls spec/halfshell_spec.rb").to eq "spec/halfshell_spec.rb\n"
      end

      specify "hs === sh === Halfshell" do
        expect(hs << "ls /").to match /bin/
        expect(sh << "ls /").to match /bin/
        expect(Halfshell << "ls /").to match /bin/
      end
    end

    context 'principle of Least Suprise' do
      let(:expect_to_respond_to) do
        lambda { |mthd| expect(half_shell).to respond_to mthd }
      end

      it '#login?' do
        expect(half_shell.login?).to be false
      end

      it '#cd #pwd' do
        [:cd, :pwd].each(&expect_to_respond_to)
        expect(half_shell.pwd).to match Regexp.new(/#{File.expand_path('.')}/i)
        half_shell.cd "/etc"
        expect(half_shell.pwd).to eq "/etc\n"
      end

      it '#ls #ll' do
        [:ls, :ll,].each(&expect_to_respond_to)
        expect(half_shell.ls).to include "Gemfile"
        expect(half_shell.ll).to include "drwx"
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

  context "reading standard error" do
    it 'is a bad method name but ill change it' do
      half_shell.type "asdfasfasfsadfd"
      expect(half_shell.gets).to match /command not found/
    end
  end

  context "making it work for me" do
    it "STDIN, STDOUT, STDERR inspect well" do
      skip "should be test on SlaveStruct"
      expect(half_shell.in.inspect).to match /STDIN/
    end

    context 'fixing shit' do
      it 'Typist should use object_id for inspect instead of ?mem addr?' do
        raph = Halfshell.new
        expect(raph.inspect).not_to match /0x0/
      end
    end
  end

  context "Collaboration" do
    context "w/terminal" do
      context "I can mock it; want a struct with 3 IOs and an int for pid" do
        let(:sub_shell) { spy }
        
        it "Typist#type calls @terminal#gets then @terminal#puts" do
          expect(sub_shell).to receive(:gets)
          expect(sub_shell).to receive(:puts)
          Halfshell::Typist.new(terminal: sub_shell).type("ls").gets
        end
      end
    end
  end
end
