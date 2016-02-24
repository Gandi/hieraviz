require 'spec_helper'

describe Hieraviz::Puppetdb do
  let(:ppdb) { Hieraviz::Puppetdb.new({}) }

  describe '.new' do
    it { expect(ppdb.instance_variable_get(:@request)).to be_a Hieracles::Puppetdb::Request }
  end

  describe '.events' do
    before do
      allow_any_instance_of(Hieracles::Puppetdb::Request)
        .to receive(:events)
        .and_return('something')
    end
    it { expect(ppdb.events).to eq 'something' }
  end
end
