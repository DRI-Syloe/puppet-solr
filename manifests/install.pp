# == Class: solr::install
#
# Full description of class solr here.
#
# === Parameters
#
#
# === Variables
#
# [*tarball*]
#   The destination full path to the solr tarball.
#
# === Examples
#
#  class { 'solr':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Copyright
#
# GPL-3.0+
#
class solr::install {

  # == variables == #
  $tarball = "${solr::solr_downloads}/solr_${solr::version}.tgz"

  # install requirements
  ensure_packages($solr::params::required_packages)

  ## create a solr user
  user {$solr::solr_user:
    ensure     => present,
    home       => $solr::solr_home,
    managehome => false,
    shell      => '/bin/bash',
    require    => Package[$solr::params::required_packages],
  }

  # directory to store downloaded solr versions
  file {$solr::solr_home:
    ensure  => directory,
    owner   => $solr::solr_user,
    group   => $solr::solr_user,
    require => User[$solr::solr_user],
  }

  file { $solr::solr_downloads:
    ensure  => directory,
    require => File[$solr::solr_home],
  }

  # download and unpackage solr
  wget::fetch{'solr':
    source      => "${solr::url}/${solr::version}/solr-${solr::version}.tgz",
    destination => $tarball,
    timeout     => 0,
    verbose     => false,
    require     => File[$solr::solr_downloads],
  }

  # extract zip
  exec {'extract solr':
    command     => "/bin/tar -C ${solr::solr_downloads} -xf ${tarball}",
    refreshonly => true,
    subscribe   => Wget::Fetch['solr'],
  }

  # copy directory
  exec {'copy solr':
    command     => "/bin/cp -r ${solr::solr_home_src}/* ${solr::solr_home}",
    refreshonly => true,
    subscribe   => Exec['extract solr'],
  }

  # change permissions
  exec {'change permissions':
    command     => "/bin/chown ${solr::solr_user}:${solr::solr_user} -R ${solr::solr_home}",
    refreshonly => true,
    subscribe   => Exec['copy solr'],
  }

}
