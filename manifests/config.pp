# @summary
#  Class configures files and directories for wireguard
# @param config_dir
#   Path to wireguard configuration files
class wireguard::config (
  Stdlib::Absolutepath    $config_dir,
) {

  file {$config_dir:
    ensure => 'directory',
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
  }
}
