# Returns the private key. Will be generated and saved to disk if it doesn't already exist.
Puppet::Functions.create_function(:'wireguard::genprivatekey') do
  # @param path Absolut path to the private key
  # @return [String] Returns the private key.
  #
  # @example Creating private key for the interface wg0.
  #   wireguard::genprivatekey('/etc/wireguard/wg0.key') => '2N0YBID3tnptapO/V5x3GG78KloA8xkLz1QtX6OVRW8='
  #
  # @example Using it as a Deferred function
  #   include wireguard
  #   wireguard::interface { 'wg0':
  #     private_key => Deferred('wireguard::genprivatekey', ['/etc/wireguard/wg0.key']),
  #     listen_port => 53098,
  #   }
  #
  dispatch :genprivatekey do
    required_param 'String', :path
    return_type 'String'
  end

  def genprivatekey(path)
    if File.exists?(path)
      private_key = File.read(path).strip
    else
      private_key = Puppet::Util::Execution.execute(
        ['/usr/bin/wg', 'genkey'],
      )
      File.write(path, private_key)
    end

    private_key
  end
end
