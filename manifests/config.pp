# == Class: solr::config
#
# Full description of class solr here.
#
# === Parameters
#
#
# === Variables
#
#
# === Examples
#
#
# === Copyright
#
# GPL-3.0+
#
class solr::config {

  anchor{'solr::config::begin':}

  # make OS specific changes
  case $::osfamily {
    'redhat': { }
    'debian':{
      file {'/usr/java':
        ensure  => directory,
        require => Anchor['solr::config::begin'],
      }

      # setup a sym link for java home
      file {'/usr/java/default':
        ensure  => 'link',
        target  => '/usr/lib/jvm/java-7-openjdk-amd64',
        require => File['/usr/java'],
        before  => File[$solr::solr_env],
      }
    }
    default: {
      fail("Unsupported OS ${::osfamily}.  Please use a debian or \
redhat based system")
    }
  }

  # create the directories
  file {$solr::solr_logs:
    ensure  => directory,
    owner   => $solr::jetty_user,
    group   => $solr::jetty_user,
    require => Anchor['solr::config::begin'],
  }

  # setup logging
#  file {"${solr::solr_home}/etc/jetty-logging.xml":
#    ensure  => file,
#    owner   => $solr::jetty_user,
#    group   => $solr::jetty_user,
#    source  => 'puppet:///modules/solr/jetty-logging.xml',
#    #require => File["${solr::solr_home}/solr"],
#    require => File[$solr::solr_home_conf],
#  }

  # setup default jetty configuration file.
  file { $solr::solr_env:
    ensure  => file,
    content => template('solr/solr.in.sh.erb'),
    require => File [$solr::solr_logs],
  }

  # setup the service level entry
  file {'/etc/init.d/solr':
    ensure  => file,
    mode    => '0755',
    content => template('solr/solr.sh.erb'),
    require => File [$solr::solr_env],
  }

  anchor {'solr::config::end':
    require => File ['/etc/init.d/solr'],
  }

}
