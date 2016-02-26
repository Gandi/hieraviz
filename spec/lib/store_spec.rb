require 'spec_helper'
require 'fileutils'

describe Hieraviz::Store do

  let(:store) { Hieraviz::Store.new('spec/files/tmp') }

  describe '.data' do
    it { expect(store.data).to eq({}) }
  end

  describe '.set' do
    let(:name) { '123456' }
    let(:value) { { a: 1 } }
    let(:tmpfile) { 'spec/files/tmp/123456' }
    before do
      store.set name, value
    end
    after do
      File.unlink(tmpfile) if File.exist?(tmpfile)
    end
    it do
      expect(File).to exist tmpfile
      expect(store.data[name]).to eq value
    end
  end

  describe '.get' do
    let(:name) { '123456' }
    let(:value) { { a: 1 } }
    let(:tmpfile) { 'spec/files/tmp/123456' }
    after do
      File.unlink(tmpfile) if File.exist?(tmpfile)
    end
    context 'without expiration and existing session' do
      before do
        store.set name, value
      end
      it do
        expect(store.get(name, false)).to eq value
        expect(File).to exist tmpfile
      end
    end
    context 'with expiration and existing unexpired session' do
      before do
        store.set name, value
      end
      it do
        expect(store.get(name, 300)).to eq value
        expect(File).to exist tmpfile
      end
    end
    context 'with expiration and existing expired session' do
      before do
        store.set name, value
        FileUtils.touch tmpfile, mtime: Time.now - 600
      end
      it do
        expect(store.get(name, 300)).to eq({})
        expect(File).not_to exist tmpfile
      end
    end
    context 'without existing session' do
      it do
        expect(store.get(name, false)).to eq({})
      end
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
    it do
      store.set name, value
      expect(File).to exist tmpfile
      expect(store.dump).to eq expected
    end
  end

  describe '.tmpfile' do
    context 'when the filename has weird chars' do
      let(:name) { 'gdahsj#@!(scg78ud' }
      let(:expected) { 'spec/files/tmp/gdahsjscg78ud' }
      it { expect(store.tmpfile(name)).to eq expected }
    end
    context 'when the filename is a normal hash' do
      let(:name) { 'gdahsjscg78ud' }
      let(:expected) { 'spec/files/tmp/gdahsjscg78ud' }
      it { expect(store.tmpfile(name)).to eq expected }
    end
  end

  describe '.init_tmpdir' do
    context 'when specified tmp dir is not present, create it' do
      let(:tmpdir_nodir) { File.expand_path('../../files/tmp_tmp', __FILE__) }
      before do
        store.init_tmpdir tmpdir_nodir
      end
      after do
        FileUtils.rm_rf(tmpdir_nodir) if Dir.exist?(tmpdir_nodir)
      end
      it { expect(File).to exist tmpdir_nodir }
    end
    context 'when tmp dir is present, returns its value' do
      let(:tmpdir_ok) { 'spec/files/tmp' }
      it { expect(store.init_tmpdir tmpdir_ok).to eq tmpdir_ok }
    end
    context 'when tmp dir is absent and cannot be created, returns /tmp' do
      let(:tmpdir_nowrite) { '/diuyao' }
      it { expect(store.init_tmpdir tmpdir_nowrite).to eq '/tmp' }
    end
  end
end
