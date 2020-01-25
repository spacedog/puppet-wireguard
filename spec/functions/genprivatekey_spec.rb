require 'spec_helper'

describe 'wireguard::genprivatekey' do
  context 'fails on invalid params' do
    it { is_expected.not_to eq(nil) }
    [
      nil,
      1,
      true,
      false,
      [],
      {},
    ].each do |value|
      it { is_expected.to run.with_params(value).and_raise_error(ArgumentError) }
    end
  end

  context 'generates a private key' do
    let(:filename) { '/etc/wireguard/wg0.key' }
    let(:privatekey) { '1234567890abcdef' }

    before do
      allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/wg', 'genkey']).and_return(privatekey)
      allow(File).to receive(:write).with(filename, privatekey)
    end

    it { is_expected.to run.with_params(filename).and_return(privatekey) }
  end

  context 'uses existing private key file' do
    let(:filename) { '/etc/wireguard/wg0.key' }
    let(:privatekey) { 'abcdef1234567890' }

    before do
      allow(File).to receive(:exists?).with(filename).and_return(true)
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(filename).and_return(privatekey)
    end

    it { is_expected.to run.with_params(filename).and_return(privatekey) }
  end
end
