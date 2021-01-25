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
#   Data type isn't 100% correct but needs to be 'Any' to allow 'Deferred'
#   on Puppet 6 systems. epp will enforce Optional[Variant[Array,String]].
# @param mtu
#   Set MTU for the wireguard interface
# @param preup
#   List of commands to run before the interface is brought up
# @param postup
#   List of commands to run after the interface is brought up
# @param predown
#   List of commands to run before the interface is taken down
# @param postup
#   List of commands to run after the interface is taken down
# @param peers
#   List of peers for wireguard interface
# @param dns
#   List of IP (v4 or v6) addresses of DNS servers to use
# @param saveconfig
#    save current state of the interface upon shutdown
# @param config_dir
#   Path to wireguard configuration files
define wireguard::interface (
  Any                             $private_key,
  Integer[1,65535]                $listen_port,
  Enum['present','absent']        $ensure   = 'present',
  Optional[Variant[Array,String]] $address  = undef,
  Optional[Integer[1,9202]]       $mtu      = undef,
  Optional[Variant[Array,String]] $preup    = undef,
  Optional[Variant[Array,String]] $postup   = undef,
  Optional[Variant[Array,String]] $predown  = undef,
  Optional[Variant[Array,String]] $postdown = undef,
  Optional[Array[Struct[
    {
      'PublicKey'           => String,
      'AllowedIPs'          => Optional[String],
      'Endpoint'            => Optional[String],
      'PersistentKeepalive' => Optional[Integer],
      'PresharedKey'        => Optional[String],
      'Comment'             => Optional[String],
    }
  ]]]                   $peers        = [],
  Optional[String]      $dns          = undef,
  Boolean               $saveconfig   = true,
  Stdlib::Absolutepath  $config_dir   = '/etc/wireguard',
) {
  $config = {
    address     => $address,
    saveconfig  => $saveconfig,
    private_key => $private_key,
    listen_port => $listen_port,
    mtu         => $mtu,
    dns         => $dns,
    preup       => $preup,
    postup      => $postup,
    predown     => $predown,
    postdown    => $postdown,
    peers       => $peers,
  }

  # $serverversion is empty on 'puppet apply' runs. Just use clientversion.
  $_serverversion = getvar('serverversion') ? {
    undef   => $clientversion,
    default => $serverversion,
  }

  # We explicitly put the template in the files directory to be able
  # use it in a Deferred function. This can later be changed into the
  # 'find_template' function which was introduced with Puppet 6.12.0.
  # At time of writing there was no Puppet Agent 6.12 release.

  # Puppet < 6 doesn't include the Deferred type and will therefore
  # fail with an compilation error while trying to load the type
  if versioncmp($clientversion, '6.0') >= 0 and versioncmp($_serverversion, '6.0') >= 0 {
    if $private_key =~ Deferred {
      $content = Deferred('inline_epp', [file("${module_name}/interface.conf.epp"), $config])
    } else {
      assert_type(String[1], $private_key)
      $content = inline_epp(file("${module_name}/interface.conf.epp"), $config)
    }
  } else {
    $content = inline_epp(file("${module_name}/interface.conf.epp"), $config)
  }

  file {"${config_dir}/${name}.conf":
    ensure    => $ensure,
    mode      => '0600',
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => $content,
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
