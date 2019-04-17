# @summary
#   Defines wireguard tunnel interfaces
# @param address
#   List of IP (v4 or v6) addresses (optionally with CIDR masks) to
#   be assigned to the interface.
# @param private_key
#   Private key for data encryption
# @param listen_port
#   The port to listen
# @param ensure
#   State of the interface
# @param peers
#   List of peers for wireguard interface
# @param saveconfig
#    save current state of the interface upon shutdown
# @param config_dir
#   Path to wireguard configuration files
define wireguard::interface (
  Variant[Array,String]     $address,
  Variant[String, Deferred] $private_key,
  Integer[1,65535]          $listen_port,
  Enum['present','absent']  $ensure = 'present',
  Optional[Array[Struct[
    {
      'PublicKey'  => Variant[String,Deferred],
      'AllowedIPs' => Optional[String],
      'Endpoint'   => Optional[String],
      'PersistentKeepalive' => Optional[Integer],
    }
  ]]]                       $peers        = [],
  Boolean                   $saveconfig   = true,
  Stdlib::Absolutepath      $config_dir   = '/etc/wireguard',
) {

  $interface_template = @(EOF)
# This file is managed by puppet
[Interface]
Address = <%= $address %>
<% if $saveconfig { -%>
SaveConfig = true
<% } -%>
PrivateKey = <%= $private_key %>
ListenPort = <%= $listen_port %>
<%- if $peers { -%>
# Peers
<% $peers.each |$peer| { -%>
[Peer]
<% $peer.each |$key,$value| { -%>
<% if $value { -%>
<%= $key %> = <%= $value %>
<% } -%>
<% } -%>
<% } -%>
<% } -%>
EOF


  $content_hash = {
    'address'     => $address,
    'private_key' => $private_key,
    'listen_port' => $listen_port,
    'peers'       => $peers,
    'saveconfig'  => $saveconfig
  }

  file {"${config_dir}/${name}.conf":
    ensure    => $ensure,
    mode      => '0600',
    owner     => 'root',
    group     => 'root',
    show_diff => false,
    content   => Deferred('inline_epp', [$interface_template, $content_hash]),
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
