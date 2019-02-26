Puppet::Functions.create_function(:'wireguard::genkey') do
  # Returns an array containing the wireguard private and public (in this order) key
  # for a certain interface.
  # @param name The interface name.
  # @return [Array] Returns [$private_key, $public_key].
  # @example Creating private and public key for the interface wg0.
  #   genkey('wg0') => [
  #     '2N0YBID3tnptapO/V5x3GG78KloA8xkLz1QtX6OVRW8=',
  #     'Pz4sRKhRMSet7IYVXXeZrAguBSs+q8oAVMfAAXHJ7S8=',
  #   ]
  dispatch :genkey do
    required_param 'String', :name
    return_type 'Array'
  end

  def genkey(name)
    private_key_path = File.join('/etc/wireguard', "#{name}.key")
    public_key_path = File.join('/etc/wireguard', "#{name}.pub")
    [private_key_path,public_key_path].each do |path|
      raise Puppet::ParseError, "#{path} is a directory" if File.directory?(path)
    end

    unless File.exists?(private_key_path)
      private_key = Puppet::Util::Execution.execute(
        ['/usr/bin/wg', 'genkey'],
      )
      File.open(private_key_path, 'w') do |f|
        f << private_key
      end
      File.delete(public_key_path)
    end

    unless File.exists?(public_key_path)
      public_key = Puppet::Util::Execution.execute(
        ['/usr/bin/wg', 'pubkey'],
        {:stdinfile => private_key_path},
      )
      File.open(public_key_path, 'w') do |f|
        f << public_key
      end
    end
    [File.read(private_key_path),File.read(public_key_path)]
  end
end

# vim: set ts=2 sw=2 :
