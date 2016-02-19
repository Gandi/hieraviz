require 'spec_helper'

describe Hieraviz::Config do

  context 'with a single puppet dir' do
    before do
      ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../../files/config.yml', __FILE__
      Hieraviz::Config.load
    end

    describe '.load' do
      let(:expected) { "spec/files/puppet" }
      it { expect(Hieraviz::Config.load['basepath']).to eq expected }
    end

    describe '.configfile' do
      let(:expected) { File.expand_path('../../files/config.yml', __FILE__) }
      it { expect(Hieraviz::Config.configfile).to eq expected }
    end

    describe '.basepaths' do
      let(:expected) { nil }
      it { expect(Hieraviz::Config.basepaths).to eq expected }
    end

    describe '.root' do
      let(:expected) { File.expand_path('../../../', __FILE__) }
      it { expect(Hieraviz::Config.root).to eq expected }
    end

    describe '.root_path' do
      context 'when path starts with a slash' do
        let(:path) { '/some/path' }
        let(:expected) { path }
        it { expect(Hieraviz::Config.root_path path).to eq expected }
      end
      context 'when path don\'t start with a slash' do
        let(:path) { 'relative/path' }
        let(:expected) { File.expand_path(File.join('../../../', path), __FILE__) }
        it { expect(Hieraviz::Config.root_path path).to eq expected }
      end
    end
  end

  context 'with multiple puppet dirs' do
    before do
      ENV['HIERAVIZ_CONFIG_FILE'] = File.expand_path '../../files/config_multi.yml', __FILE__
      Hieraviz::Config.load
    end

    describe '.basepaths' do
      let(:expected) { 
        [
          File.expand_path('../../../spec/files/puppet', __FILE__),
          File.expand_path('../../../spec/files/puppet2', __FILE__)
        ]
      }
      it { expect(Hieraviz::Config.basepaths).to match_array(expected) }
    end

  end

end
