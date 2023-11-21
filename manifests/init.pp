# @summary Installs solr using the embedded version of jetty.
# Configures solr and starts the service.
#
# If using Centos, the firewall rules need to be configured as shown:
#
#    ```
#     add IP Tables
#     /sbin/iptables -I INPUT 1 -p tcp --dport 8983 -j ACCEPT
#     /sbin/service iptables save
#     service iptables restart
#    ```
#
# @param version
#   The version to install.
#
# @param url
#   The url of the source repository for apache solr.
#
# @param url_user
#   If the URL is password protected, the user name.
#
# @param url_pass
#   If the URL is password protected, the password.
#
# @param manage_user
#   Whether to manage the solr user or not
#
# @param solr_user
#   Run Solr as this user ID.
#   Note, creates this user.
#
# @param solr_host
#   Listen to connections from this network host
#   Use 0.0.0.0 as solr_host to accept all connections.
#
# @param solr_port
#   The network port used by Jetty
#
# @param solr_timezone
#   The timezone used by Jetty
#
# @param solr_heap
#   The heap size used by jetty.
#
# @param solr_java_mem
#   If you want finer control over memory options, specify them directly with this variable.
#   Arguments should be in the following format: "-Xms512m -Xmx512m"
#   Note, the solr_heap parameter will not be used.
#
# @param solr_downloads
#   Contains the solr tarballs and extracted dirs.
#
# @param install_dir
#   The install directory (`-i`) parameter passed to the solr installer.
#
# @param install_dir_mg
#   Sets if this module should manage the install directory.
#   True if this module should manage and false otherwise.
#
# @param install_options
#   String of options to be passed to install_solr_service.sh script.
#   The default option -n does not start Solr service after install, and does not abort on missing Java.
#   Only valid for Solr version 6.3.0+.
#   For versions less than 6.3.0, set to empty string.
#
# @param solr_home
#   The home directory for solr.
#
# @param solr_options
#   Additional options added to java start command line in addition to other options.
#
# @param var_dir
#   The var directory for solr.
#
# @param solr_logs
#   The directory for the solr logs.
#
# @param java_home
#   The directory that contains the jvm.
#   Default: (os specific)
#     * Debian/Ubuntu: '/usr/lib/jvm/java-8-openjdk-amd64/jre'
#     * CentOS/RHEL: '/usr/lib/jvm/jre-1.8.0'
#
# @param manage_java
#   True if this class should manage java and false if java is managed outside of this class.
#
# @param solr_environment
#   Bash style environment variables passed at the end of the solr
#   server environment.
#
# @param limit_nofile
#   Sets number of open files limit in systemd service file.
#
# @param limit_nproc
#   Sets number of processes limit in systemd service file.
#
# @param cores
#   An array of hashes that define a core which will be created with the
#   create_resources function.
#   See type solr::core for details.
#
# @param required_packages
#   Specified in params and is platform dependent.
#
# @param zk_hosts
#   For configuring ZooKeeper ensemble.
#
# @param zk_service
#   If Zookeeper is running on this node, ensure the Solr service starts
#   before zk_service.
#
# @param log4j_maxfilesize
#   Maximum allowed log file size (in bytes) before rolling over.
#   Suffixes "KB", "MB" and "GB" are allowed.
#
# @param log4j_maxbackupindex
#   Maximum number of log backup files to keep.
#
# @param log4j_rootlogger_loglevel
#   The loglevel to set for log4j.
#
# @param log4j_console
#   The log4j console configuration.
#
# @param log4j_console_layout
#   The log4j console layout configuration.
#
# @param log4j_console_layout_conversion
#   The log4j console layout conversion pattern configuration.
#
# @param enable_remote_jmx
#   Uses enable_remote_jmx_opts in the configuration.
#
# @param remote_jmx_port
#   The port to use for remote jmx connections.
#
# @param schema_name
#   The Solr cores' schema name. This should be set to `schema.xml` if using
#   the classic schema.xml method. If using a managed schema, set this to
#   Solr's "managedSchemaResourceName" setting, typically 'manage-schema'.
#   Refer to Solr's documentation for `core.properties` for details.
#   Default: varies by version:
#     Solr >= 5.6.0 will use 'manage-schema'
#     Solr < 5.6.0 will default to 'schema.xml'
#
# @param ssl_key_store
#  The path to the key store.  If the key store is in the solr's home/etc
#  directory, than can be etc/KEY_STORE_FILE
#
# @param ssl_key_store_password
#   The secret password of the key store.  Required if ssl_key_store is set.
#
# @param ssl_key_store_type
#   The type of key store.
#
# @param ssl_trust_store
#   If ssl_key_store is set and ssl_trust_store is undef, the settings
#   will use the key store as the trust store.  This can be set to
#   an indepenent trust store.
#  
# @param ssl_trust_store_password
#   The password to the trust store.  If undef and ssl_key_store_password
#   is set, the trust store password will use the key store's password.
#
# @param ssl_trust_store_type
#   The type of trust store.
#
# @param ssl_need_client_auth
#  Set to true if the client requires authentication.
#
# @param ssl_want_client_auth
#   Enables the client to authenticate but is not required.
#
# @param ssl_client_key_store
#   If undef, will use values set for ssl_key_store for clients.
#
# @param ssl_client_key_store_password
#   If undef, will use values set for ssl_key_store_password for clients.
#
# @param ssl_client_trust_store
#   If undef, will use values set for ssl_trust_store for clients.
#
# @param ssl_client_trust_store_password 
#   If undef, will use values set for ssl_trust_store_password for clients.
#
# @example
#
#   include solr
#
class solr (
  String            $version                         = '6.6.6',
  String            $url                             = 'http://archive.apache.org/dist/lucene/solr/',
  Optional[String]  $url_user                        = undef,
  Optional[String]  $url_pass                        = undef,
  Boolean           $manage_user                     = true,
  String            $solr_user                       = 'solr',
  String            $solr_host                       = '127.0.0.1',
  String            $solr_port                       = '8983',
  String            $solr_timezone                   = 'UTC',
  String            $solr_heap                       = '512m',
  Optional[String]  $solr_java_mem                   = undef,
  String            $solr_downloads                  = '/opt/solr_downloads',
  String            $install_dir                     = '/opt',
  Boolean           $install_dir_mg                  = false,
  String            $install_options                 = '-n',
  String            $var_dir                         = '/var/solr',
  String            $solr_logs                       = '/var/log/solr',
  String            $solr_home                       = '/opt/solr/server/solr',
  Optional[Array]   $solr_options                    = undef,
  String            $java_home                       = $solr::params::java_home,
  Boolean           $manage_java                     = true,
  Optional[Array]   $solr_environment                = undef,
  Integer           $limit_nofile                    = 65000,
  Integer           $limit_nproc                     = 65000,
  Hash              $cores                           = {},
  Array             $required_packages               = $solr::params::required_packages,
  Optional[Array]   $zk_hosts                        = undef,
  Optional[String]  $zk_service                      = undef,
  String            $log4j_maxfilesize               = '4MB',
  String            $log4j_maxbackupindex            = '9',
  Variant[
    Enum['ALL', 'DEBUG', 'ERROR', 'FATAL',
      'INFO', 'OFF', 'TRACE',
      'TRACE_INT', 'WARN',
    ],
    String
  ]                 $log4j_rootlogger_loglevel       = 'INFO',
  String            $log4j_console                   = 'org.apache.log4j.ConsoleAppender',
  String            $log4j_console_layout            = 'org.apache.log4j.EnhancedPatternLayout',
  String            $log4j_console_layout_conversion =
    '%d{yyyy-MM-dd HH:mm:ss.SSS} %-5p (%t) [%X{collection} %X{shard} %X{replica} %X{core}] %c{1.} %m%n',
  Boolean           $enable_remote_jmx               = false,
  Optional[String]  $remote_jmx_port                 = undef,
  Optional[String]  $schema_name                     = undef,
  Optional[String]  $ssl_key_store                   = undef,
  Optional[String]  $ssl_key_store_password          = undef,
  String            $ssl_key_store_type              = 'JKS',
  Optional[String]  $ssl_trust_store                 = undef,
  Optional[String]  $ssl_trust_store_password        = undef,
  String            $ssl_trust_store_type            = 'JKS',
  Optional[Boolean] $ssl_need_client_auth            = undef,
  Optional[Boolean] $ssl_want_client_auth            = undef,
  Optional[String]  $ssl_client_key_store            = undef,
  Optional[String]  $ssl_client_key_store_password   = undef,
  Optional[String]  $ssl_client_trust_store          = undef,
  Optional[String]  $ssl_client_trust_store_password = undef,
) inherits solr::params {
  ## === Variables === ##
  $solr_env       = $solr::params::solr_env
  # The directory that contains cores.
  $solr_core_home = $solr_home
  $solr_pid_dir   = $var_dir
  $solr_bin       = "${install_dir}/solr/bin"
  $solr_server    = "${install_dir}/solr/server"
  # The directory to install shared libraries for use by solr.
  $solr_lib_dir   = "${solr_server}/solr-webapp/webapp/WEB-INF/lib"

  # The directory to the basic configuration example core.
  if versioncmp($solr::version, '7.0.0') >= 0 {
    $basic_dir    = "${solr_server}/solr/configsets/_default/conf"
  } else {
    $basic_dir    = "${solr_server}/solr/configsets/basic_configs/conf"
  }

  # If no value for `schema_name` is provided, use a sensible default for this
  # version of Solr.
  case $schema_name {
    undef: {
      # I have confirmed that managed-schema doesn't work in 5.5.3
      # So I am pushing to version 5.6.0.
      if versioncmp($solr::version, '5.6.0') >= 0 {
        $schema_filename = 'managed-schema'
      } else {
        $schema_filename = 'schema.xml'
      }
    }
    default: {
      $schema_filename = $schema_name
    }
  }

  contain solr::install
  contain solr::config
  contain solr::service

  Class['solr::install'] -> Class['solr::config']
  Class['solr::config'] ~> Class['solr::service']

  create_resources(::solr::core, $cores)
}
