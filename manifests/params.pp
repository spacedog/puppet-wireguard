# @summary
#  Class that contains OS specific parameters for other classes
class wireguard::params {
  case $facts['os']['name'] {
    'RedHat', 'CentOS': {
      $manage_package = true
      $manage_repo    = true
      $package_name   = ['wireguard-dkms', 'wireguard-tools']
      $repo_url       = 'https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo'
      $config_dir     = '/etc/wireguard'
    }
    defaut: {
      fail("Unsupported OS family")
    }
  }
}
