# Returns an array containing the wireguard private and public (in this order) key for a certain interface.
Puppet::Functions.create_function(:'wireguard::genkey') do
  # @param name The interface name.
  # @param path Absolut path to the wireguard key files (default '/etc/wireguard').
  # @return [Array] Returns [$private_key, $public_key].
  # @example Creating private and public key for the interface wg0.
  #   wireguard::genkey('wg0', '/etc/wireguard') => [
  #     '2N0YBID3tnptapO/V5x3GG78KloA8xkLz1QtX6OVRW8=',
  #     'Pz4sRKhRMSet7IYVXXeZrAguBSs+q8oAVMfAAXHJ7S8=',
  #   ]
  dispatch :genkey do
    required_param 'String', :name
    optional_param 'String', :path
    return_type 'Array'
  end

  def genkey(name, path='/etc/wireguard')
    private_key_path = File.join(path, "#{name}.key")
    public_key_path = File.join(path, "#{name}.pub")
    [private_key_path,public_key_path].each do |p|
      raise Puppet::ParseError, "#{p} is a directory" if File.directory?(p)
      dir = File.dirname(p)
      raise Puppet::ParseError, "#{dir} is not writable" if not File.writable?(dir)
    end

    private_key = call_function('wireguard::genprivatekey', private_key_path)
    public_key  = call_function('wireguard::genpublickey', private_key_path, public_key_path)
    [private_key, public_key]
  end
end

# vim: set ts=2 sw=2 :
