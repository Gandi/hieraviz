require 'spec_helper'

describe Hieraviz::Facts do

  let(:tmpdir) { "spec/files/tmp" }
  let(:base) { "base" }
  let(:node) { "node" }
  let(:user) { "dummy" }
  let(:facts) { Hieraviz::Facts.new tmpdir, base, node, user }
  let(:expected) { "spec/files/tmp/base__node__dummy" }

  describe '.new' do
    it { expect(facts.instance_variable_get(:@filename)).to eq expected }
  end

  describe '.exist?' do
    context 'when file exists' do
      before { FileUtils.touch expected }
      after  { File.unlink expected }
      it { expect(facts.exist?).to be_truthy }
    end
    context 'when file does not exist' do
      it { expect(facts.exist?).to be_falsey }
    end
  end

  describe '.write' do
    let(:data) { Object.new }
    before { facts.write(data) }
    after  { File.unlink expected }
    it { expect(File).to exist(expected) }
  end

  describe '.read' do
    let(:data) { { a: 'b'} }
    before { facts.write(data) }
    after  { File.unlink expected }
    it { expect(facts.read).to eq data }
  end

end
