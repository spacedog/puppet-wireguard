require 'spec_helper'

describe 'wireguard::genpublickey' do
  let(:private_key_path) { '/etc/wireguard/wg0.key' }
  let(:public_key_path) { '/etc/wireguard/wg0.pub' }

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

  context 'generates a public key' do
    let(:publickey) { '1234567890abcdef' }

    before do
      allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/wg', 'pubkey'], {:stdinfile => private_key_path}).and_return(publickey)
      allow(File).to receive(:write).with(public_key_path, publickey)
    end

    it { is_expected.to run.with_params(private_key_path, public_key_path).and_return(publickey) }
  end

  context 'uses existing public key file' do
    let(:publickey) { 'abcdef1234567890' }

    before do
      allow(File).to receive(:exists?).with(public_key_path).and_return(true)
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with(public_key_path).and_return(publickey)
    end

    it { is_expected.to run.with_params(private_key_path, public_key_path).and_return(publickey) }
  end
end
