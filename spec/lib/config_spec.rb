require 'spec_helper'

describe Hieraviz::Config do

  before do
    ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../../files/config.yml', __FILE__
  end

  describe '.load' do
    let(:expected) { "spec/files/puppet" }
    it { expect(Hieraviz::Config.load['basepath']).to eq expected }
  end

  describe '.configfile' do
    let(:expected) { File.expand_path('../../files/config.yml', __FILE__) }
    it { expect(Hieraviz::Config.configfile).to eq expected }
  end

  describe '.root' do
    let(:expected) { File.expand_path('../../../', __FILE__) }
    it { expect(Hieraviz::Config.root).to eq expected }
  end

end
