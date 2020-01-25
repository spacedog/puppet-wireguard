require 'spec_helper'

describe 'wireguard::genkey' do
  let(:name) { 'wg0' }
  let(:private_key_path) { '/etc/wireguard/wg0.key' }
  let(:public_key_path) { '/etc/wireguard/wg0.pub' }
  let(:privatekey) { 'privatekey' }
  let(:publickey) { 'publickey' }


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

  context 'generates a private and public key' do
    before do
      allow(File).to receive(:writable?).with('/etc/wireguard').and_return(true)

      # Privatekey
      allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/wg', 'genkey']).and_return(privatekey)
      allow(File).to receive(:write).with(private_key_path, privatekey)

      # Publickey
      allow(Puppet::Util::Execution).to receive(:execute).with(['/usr/bin/wg', 'pubkey'], {:stdinfile => private_key_path}).and_return(publickey)
      allow(File).to receive(:write).with(public_key_path, publickey)
    end

    it { is_expected.to run.with_params(name).and_return([privatekey, publickey]) }
  end

  context 'uses existing private and public key file' do
    before do
      allow(File).to receive(:writable?).with('/etc/wireguard').and_return(true)
      allow(File).to receive(:read).and_call_original

      # Private Key
      allow(File).to receive(:exists?).with(private_key_path).and_return(true)
      allow(File).to receive(:read).with(private_key_path).and_return(privatekey)

      # Public Key
      allow(File).to receive(:exists?).with(public_key_path).and_return(true)
      allow(File).to receive(:read).with(public_key_path).and_return(publickey)
    end

    it { is_expected.to run.with_params(name).and_return([privatekey, publickey]) }
  end
end
