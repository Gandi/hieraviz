require 'spec_helper'

describe Hieraviz::Store do

  describe '.data' do
    it { expect(Hieraviz::Store.data).to eq Hash.new }
  end

end
