# @summary
#  Class installs wireguard packages and sets yum repository
# @param package_name
#   Name the package(s) that installs wireguard
# @param repo_url
#   URL of wireguard repo
# @manage_repo
#   Should class manage yum repo
# @manage_package
#   Should class install package(s)
# @package_ensure
#   Set state of the package
class wireguard::install (
  Variant[Array, String] $package_name,
  String                 $repo_url,
  Boolean                $manage_repo,
  Boolean                $manage_package,
  Variant[Boolean, Enum['installed','latest','present']] $package_ensure,
) {

  if $manage_repo {
    exec {'download_wireguard_repo':
      command => "/bin/curl -Lo /etc/yum.repos.d/wireguard.repo ${repo_url}",
      creates => '/etc/yum.repos.d/wireguard.repo',
    }
  }

  $_require = $manage_repo ? {
    true    => Exec['download_wireguard_repo'],
    default => '',
  }

  if $manage_package {
    package {$package_name:
      ensure  => $package_ensure,
      require => $_require,
    }
  }
}
