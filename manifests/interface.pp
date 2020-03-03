# @summary
#   Defines wireguard tunnel interfaces
# @param private_key
#   Private key for data encryption
# @param listen_port
#   The port to listen
# @param ensure
#   State of the interface
# @param address
#   List of IP (v4 or v6) addresses (optionally with CIDR masks) to
#   be assigned to the interface.
# @param peers
#   List of peers for wireguard interface
# @param saveconfig
#    save current state of the interface upon shutdown
# @param config_dir
#   Path to wireguard configuration files
define wireguard::interface (
  String                          $private_key,
  Integer[1,65535]                $listen_port,
  Enum['present','absent']        $ensure  = 'present',
  Optional[Variant[Array,String]] $address = undef,
  Optional[Array[Struct[
    {
      'PublicKey'           => String,
      'AllowedIPs'          => Optional[String],
      'Endpoint'            => Optional[String],
      'PersistentKeepalive' => Optional[Integer],
      'PresharedKey'        => Optional[String],
    }
  ]]]                   $peers        = [],
  Boolean               $saveconfig   = true,
  Stdlib::Absolutepath  $config_dir   = '/etc/wireguard',
  Optional[String]      $preup        = undef,
  Optional[String]      $postup       = undef,
  Optional[String]      $predown      = undef,
  Optional[String]      $postdown     = undef,
) {

  file {"${config_dir}/${name}.conf":
    ensure    => $ensure,
    mode      => '0600',
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => template("${module_name}/interface.conf.erb"),
    notify    => Service["wg-quick@${name}.service"],
  }

  $_service_ensure = $ensure ? {
    'absent' => 'stopped',
    default  => 'running',
  }
  $_service_enable = $ensure ? {
    'absent' => false,
    default  => true,
  }

  service {"wg-quick@${name}.service":
    ensure   => $_service_ensure,
    provider => 'systemd',
    enable   => $_service_enable,
    require  => File["${config_dir}/${name}.conf"],
  }
}
