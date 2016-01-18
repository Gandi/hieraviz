require 'spec_helper'
require 'fileutils'

describe Hieraviz::Store do

  describe '.data' do
    it { expect(Hieraviz::Store.data).to eq Hash.new }
  end

  describe '.set' do
    let(:name) { '123456' }
    let(:value) { { a: 1 } }
    let(:tmpfile) { 'spec/files/tmp/123456' }
    after do
      File.unlink(tmpfile) if File.exist?(tmpfile)
    end
    it {
      Hieraviz::Store.set name, value
      expect(File).to exist tmpfile
      expect(Hieraviz::Store.data[name]).to eq value
    }
  end

  describe '.get' do
    let(:name) { '123456' }
    let(:value) { { a: 1 } }
    let(:tmpfile) { 'spec/files/tmp/123456' }
    after do
      File.unlink(tmpfile) if File.exist?(tmpfile)
    end
    context "without expiration and existing session" do
      before do
        Hieraviz::Store.set name, value
      end
      it {
        expect(Hieraviz::Store.get(name)).to eq value
        expect(File).to exist tmpfile
      }
    end
    context "with expiration and existing unexpired session" do
      before do
        Hieraviz::Store.set name, value
      end
      it {
        expect(Hieraviz::Store.get(name, 300)).to eq value
        expect(File).to exist tmpfile
      }
    end
    context "with expiration and existing expired session" do
      before do
        Hieraviz::Store.set name, value
        FileUtils.touch tmpfile, mtime: Time.now - 600
      end
      it {
        expect(Hieraviz::Store.get(name, 300)).to be_falsey
        expect(File).not_to exist tmpfile
      }
    end
    context "without existing session" do
      it {
        expect(Hieraviz::Store.get(name)).to be_falsey
      }
    end
  end

  describe '.dump' do
    let(:name) { '123456' }
    let(:value) { { a: 1 } }
    let(:tmpfile) { 'spec/files/tmp/123456' }
    let(:expected) { { name => value } }
    after do
      File.unlink(tmpfile) if File.exist?(tmpfile)
    end
    it {
      Hieraviz::Store.set name, value
      expect(File).to exist tmpfile
      expect(Hieraviz::Store.dump).to eq expected
    }
  end

  describe '.tmpfile' do
    context "when the filename has weird chars" do
      let(:name) { 'gdahsj#@!(scg78ud' }
      let(:expected) { 'spec/files/tmp/gdahsjscg78ud' }
      it { expect(Hieraviz::Store.tmpfile(name)).to eq expected }
    end
    context "when the filename is a normal hash" do
      let(:name) { 'gdahsjscg78ud' }
      let(:expected) { 'spec/files/tmp/gdahsjscg78ud' }
      it { expect(Hieraviz::Store.tmpfile(name)).to eq expected }
    end
  end

  describe '.tmpdir' do
    let(:tmpdir_ok) { 'spec/files/tmp' }
    before do
      allow(Hieraviz::Config).to receive(:load).and_return({ 'tmpdir' => tmpdir_ok })
    end
    it { expect(Hieraviz::Store.tmpdir).to eq tmpdir_ok }
  end

  describe '.init_tmpdir' do
    context 'when specified tmp dir is not present, create it' do 
      let(:tmpdir_nodir) { File.expand_path('../../files/tmp_tmp', __FILE__) }
      before do
        allow(Hieraviz::Config).to receive(:load).and_return({ 'tmpdir' => tmpdir_nodir })
        tmpexpect = Hieraviz::Store.init_tmpdir
      end
      after do
        FileUtils.rm_rf(tmpdir_nodir) if Dir.exist?(tmpdir_nodir)
      end
      it { expect(File).to exist tmpdir_nodir }
    end
    context 'when tmp dir is present, returns its value' do
      let(:tmpdir_ok) { 'spec/files/tmp' }
      it { expect(Hieraviz::Store.init_tmpdir).to eq tmpdir_ok }
    end
    context 'when tmp dir is absent and cannot be created, returns /tmp' do
      let(:tmpdir_nowrite) { '/diuyao' }
      before do
        allow(Hieraviz::Config).to receive(:load).and_return({ 'tmpdir' => tmpdir_nowrite })
      end
      it { expect(Hieraviz::Store.init_tmpdir).to eq '/tmp' }
    end
  end

end
