require 'shell'
require 'pry'

RSpec.describe AndyDNA::Shell do
  context 'OO interface to subShells' do
    let(:shell) { AndyDNA::Shell.new }

    let(:expect_to_respond_to) do
      lambda { |mthd| expect(shell).to respond_to mthd }
    end

    context 'principle of Least Suprise' do

      it '#stdin #stdout #stderr #pid' do
        [:stdin, :stdout, :stderr, :pid].each(&expect_to_respond_to)
      end

      it 'aliases #in #out #err' do
        [:in, :out, :err].each(&expect_to_respond_to)
      end

      it '#login?' do
        expect(shell).to respond_to :login?
      end

      it '#cd #pwd #cwd' do
        [:cd, :pwd, :cwd].each(&expect_to_respond_to)
      end

      it '#ls #ll' do
        [:ls, :ll,].each(&expect_to_respond_to)
      end

      it '#clear' do
        [:clear].each(&expect_to_respond_to)
      end

      it '#su' do
        [:su].each(&expect_to_respond_to)
      end

      it '#exit' do
        [:exit].each(&expect_to_respond_to)
      end
    end

    context 'dynamic messages mean arguments to commands' do

      it '#lsa #lsb #lsc ... #lsz' do
        ('a'..'z').map{|ltr|"ls#{ltr}".to_sym}.each(&expect_to_respond_to)
      end
    end

    context 'wire up open4' do
      it 'ls' do
        expect(shell.ls).to match /lib/
      end

      it 'shovel in arbitrary commands' do
        expect(shell << "which sh").to match Regexp.new("/bin/sh")
      end
    end
  end
end
