require 'spec_helper'

describe Hieraviz::Facts do

  describe '.new' do
    let(:tmpdir) { "spec/files/tmp" }
    let(:base) { "base" }
    let(:node) { "node" }
    let(:user) { "dummy" }
    let(:facts) { Hieraviz::Facts.new tmpdir, base, node, user }
    let(:expected) { "spec/files/tmp/base__node__dummy" }
    it { expect(facts.instance_variable_get(:@filename)).to eq expected }
  end


end
