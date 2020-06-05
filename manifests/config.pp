# @summary
#  Class configures files and directories for wireguard
# @param config_dir
#   Path to wireguard configuration files
# @param config_dir_mode
#   The config_dir access mode bits
class wireguard::config (
  Stdlib::Absolutepath $config_dir,
  String               $config_dir_mode,
  Boolean              $config_dir_purge,
) {

  if $config_dir_purge {
    file {$config_dir:
      ensure  => 'directory',
      mode    => $config_dir_mode,
      owner   => 'root',
      group   => 'root',
      force   => true,
      recurse => true,
      purge   => true,
    }
  } else {
    file {$config_dir:
      ensure => 'directory',
      mode   => $config_dir_mode,
      owner  => 'root',
      group  => 'root',
    }
  }
}
