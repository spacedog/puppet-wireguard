# @summary
#  Class that contains OS specific parameters for other classes
class wireguard::params {
  $config_dir_mode    = '0700'
  $config_dir_purge   = false
  $manage_package     = true
  $config_dir         = '/etc/wireguard'
  case $facts['os']['name'] {
    'RedHat', 'CentOS', 'VirtuozzoLinux': {
      if versioncmp($facts['os']['release']['major'],'9') < 0 {
        $manage_repo    = true
        $package_name   = ['wireguard-dkms', 'wireguard-tools']
        $repo_url       = 'https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo'
      } else {
        $manage_repo    = false
        $package_name   = ['wireguard']
        $repo_url       = ''
      }
    }
    'Ubuntu': {
      $manage_repo    = false
      $package_name   = ['wireguard']
      $repo_url       = ''
    }
    'Debian': {
      $manage_repo    = true
      $package_name   = ['wireguard', 'wireguard-dkms', 'wireguard-tools']
      $repo_url       = 'http://deb.debian.org/debian/'
    }
    default: {
      warning("Unsupported OS family, couldn't configure package automatically")
    }
  }
}
