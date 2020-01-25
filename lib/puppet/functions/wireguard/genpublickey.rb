# Returns a public key derived from a private key.
# Will be generated and saved to disk if it doesn't already exist.
Puppet::Functions.create_function(:'wireguard::genpublickey') do
  # @param private_key_path Absolut path to the private key
  # @param public_key_path Absolut path to the public key
  # @return [String] Returns the public key.
  #
  # @example Creating public key for the interface wg0.
  #   wireguard::genpublickey('/etc/wireguard/wg0.key',
  #                            '/etc/wireguard/wg0.pub'
  #                           ) => 'gNaMjIpR7LKg019iktKJC74GX/MD3Y35Wo+WRNRQZxA='
  #
  dispatch :genprivkey do
    required_param 'String', :private_key_path
    required_param 'String', :public_key_path
    return_type 'String'
  end

  def genprivkey(private_key_path, public_key_path)
    if File.exists?(public_key_path)
      public_key = File.read(public_key_path).strip
    else
      public_key = Puppet::Util::Execution.execute(
        ['/usr/bin/wg', 'pubkey'],
        {:stdinfile => private_key_path},
      )
      File.write(public_key_path, public_key)
    end

    public_key
  end
end
