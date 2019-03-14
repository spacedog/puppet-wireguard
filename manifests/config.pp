# @summary
#  Class configures files and directories for wireguard
# @param config_dir
#   Path to wireguard configuration files
class wireguard::config (
  Stdlib::Absolutepath $config_dir,
  String               $config_dir_mode,
) {

  file {$config_dir:
    ensure => 'directory',
    mode   => $config_dir_mode,
    owner  => 'root',
    group  => 'root',
  }
}
