# == Class: pgpool2
#
# https://github.com/infoxchange/puppet-pgpool2
#
# Puppet (3.x) module for setting up pgpool-II PostgreSQL clusters
# This is a fork of the unmaintained iksteen/puppet-pgpool2 module
#
# Requires pgpool-II 3.3 or higher
#
# === Examples
#
#  class { pgpool2:
#
#    backends              => [
#      {
#        'hostname'        => 'db-server-01',
#        'weight'          => 1,
#        'data_directory'  => '/data',
#        'flag'            => 'ALLOW_TO_FAILOVER',
#      },
#
#      {
#        'hostname'        => 'db-server-02',
#        'weight'          => 1,
#        'data_directory'  => '/data',
#        'flag'            => 'ALLOW_TO_FAILOVER',
#      }
#    ],
#
#    pgclients             =>
#      {
#        'my-web-server'   => '192.168.0.100/32',
#      },
#
#    pgpoolpasswd          =>
#      {
#        'username'        => 'md5ofpassword',
#      },
#
#    backend_port          => 5432,
#    listen_addresses      => '*',
#    replication_mode      => true,
#
#    # Logging configuration
#    load_balance_mode     => true,
#    log_destination       => 'syslog',
#    log_connections       => true,
#    log_hostname          => true,
#    debug_level           => 1,
#
#  }
#
# === Authors
#
# Author Name Sam McLeod
#

class pgpool2(
  $package_name                         = undef,
  $package_ensure                       = 'present',
  $confdir                              = undef,
  $service_name                         = undef,
  $conf_owner                           = 'root',
  $conf_group                           = 'postgres',
  # == pgpool2.conf ==

  # CONNECTIONS
  # pgpool connection settings
  $listen_addresses                     = 'localhost',
  $port                                 = 5433,
  $socket_dir                           = undef,
  # pcp connection settings
  $pcp_port                             = 9898,
  $pcp_socket_dir                       = undef,
  # backend connection settings
  $backends                             = [],
  $backend_port                         = 5432,
  $backend_weight                       = 1,
  # authentication
  $enable_pool_hba                      = false,
  $authentication_timeout               = 60,
  # SSL connections
  $ssl                                  = false,
  $ssl_key                              = undef,
  $ssl_cert                             = undef,
  $ssl_ca_cert                          = undef,
  $ssl_ca_cert_dir                      = undef,

  # POOLS
  # Pool size
  $num_init_children                    = 32,
  $max_pool                             = 4,
  # Life time
  $child_life_time                      = 300,
  $child_max_connections                = 0,
  $connection_life_time                 = 0,
  $client_idle_limit                    = 0,

  # LOGS
  # Where to log
  $log_destination                      = 'stderr',
  # What to log
  $print_timestamp                      = true,
  $log_connections                      = false,
  $log_hostname                         = false,
  $log_statement                        = false,
  $log_per_node_statement               = false,
  $log_standby_delay                    = 'none',
  # Syslog specific
  $syslog_facility                      = 'LOCAL0',
  $syslog_ident                         = 'pgpool',
  # Debug
  $debug_level                          = 0,

  # FILE LOCATIONS
  $pid_file_name                        = undef,
  $logdir                               = undef,

  # CONNECTION POOLING
  $connection_cache                     = true,
  $reset_query_list                     = ['ABORT', 'DISCARD ALL'],

  # REPLICATION MODE
  $replication_mode                     = false,
  $replicate_select                     = false,
  $insert_lock                          = true,
  $lobj_lock_table                      = '',
  # Degenerate handling
  $replication_stop_on_mismatch         = false,
  $failover_if_affected_tuples_mismatch = false,

  # LOAD BALANCING MODE
  $load_balance_mode                    = false,
  $ignore_leading_white_space           = true,
  $white_function_list                  = [],
  $black_function_list                  = ['nextval', 'setval'],

  # MASTER/SLAVE MODE
  $master_slave_mode                    = false,
  $master_slave_sub_mode                = 'slony',

  # Streaming
  $sr_check_period                      = 0,
  $sr_check_user                        = 'nobody',
  $sr_check_password                    = '',
  $delay_threshold                      = 0,
  # Special commands
  $follow_master_command                = '',

  # PARALLEL MODE AND QUERY CACHE
  $parallel_mode                        = false,
  $enable_query_cache                   = false,
  $pgpool2_hostname                     = '',

  # System DB info
  $system_db_hostname                   = 'localhost',
  $system_db_port                       = 5432,
  $system_db_dbname                     = 'pgpool',
  $system_db_schema                     = 'pgpool_catalog',
  $system_db_user                       = 'pgpool',
  $system_db_password                   = '',

  # HEALTH CHECK
  $health_check_period                  = 0,
  $health_check_timeout                 = 20,
  $health_check_user                    = 'nobody',
  $health_check_password                = '',

  # FAILOVER AND FAILBACK
  $failover_command                     = '',
  $failback_command                     = '',
  $fail_over_on_backend_error           = true,

  # ONLINE RECOVERY
  $recovery_user                        = 'nobody',
  $recovery_password                    = '',
  $recovery_1st_stage_command           = '',
  $recovery_2nd_stage_command           = '',
  $recovery_timeout                     = 90,
  $client_idle_limit_in_recovery        = 0,

  # MEMORY CACHE
  $memory_cache_enable                  = 'on',
  $memqcache_method                     = 'shmem',
  $memqcache_expire                     = 0,
  $memqcache_auto_cache_invalidation    = 'on',
  $memqcache_maxcache                   = 1,
  $white_memqcache_table_list           = undef,
  $black_memqcache_table_list           = undef,
  $memqcache_oiddir                     = undef,

  # WATCHDOG
  $use_watchdog                         = false,
  $wd_hostname                          = '',
  $wd_authkey                           = '',
  $ping_path                            = '/bin',
  $trusted_servers                      = '',
  $wd_port                              = 9000,
  $delegate_IP                          = undef,
  $other_pgpool_hostname0               = undef,
  $other_pgpool_port0                   = 9898,
  $other_wd_port0                       = 9000,
  $clear_memqcache_on_escalation        = 'on',
  $wd_escalation_command                = '',

  # Lifecheck
  $wd_lifecheck_method                  = 'heartbeat',
  $wd_interval                          = 10,
  $wd_heartbeat_port                    = 9899,
  $wd_heartbeat_keepalive               = 2,
  $wd_heartbeat_deadtime                = 200,
  $heartbeat_destination0               = '',
  $heartbeat_destination_port0          = 9899,
  $heartbeat_device0                    = 'eth0',
  $wd_lifecheck_query                   = 'SELECT 1',
  $wd_life_point                        = 3,
  $wd_lifecheck_dbname                  = 'postgres',
  $wd_lifecheck_user                    = 'postgres',
  $wd_lifecheck_password                = '',

  # Switching virtual IP address
  $ifconfig_path                        = '/usr/bin',
  $if_up_cmd                            = 'sudo ifconfig eth0:0 inet $_IP_$ netmask 255.255.254.0',
  $if_down_cmd                          = 'sudo ifconfig eth0:0 down',
  $arping_path                          = '/usr/bin',
  $arping_cmd                           = 'sudo arping -U $_IP_$ -w 1',

  # Authentication
  $pgclients                             = [],
  $pgpoolpasswd                          = [],

  # OTHERS
  $relcache_expire                       = 0,
) {
  class { 'pgpool2::params':
    custom_package_name   => $package_name,
    custom_confdir        => $confdir,
    custom_service_name   => $service_name,
    custom_socket_dir     => $socket_dir,
    custom_pcp_socket_dir => $pcp_socket_dir,
    custom_pid_file_name  => $pid_file_name,
    custom_logdir         => $logdir,
  }

  package { 'pgpool2':
    ensure => $package_ensure,
    name   => $pgpool2::params::package_name,
  }

  package { 'iputils-arping':
    ensure => latest,
  }

  file { 'pgpool.conf':
    ensure  => 'present',
    path    => "${pgpool2::params::confdir}/pgpool.conf",
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => '0640',
    content => template('pgpool2/pgpool.erb'),
    require => Package['pgpool2'],
    notify  => Service['pgpool2'],
  }

  file { 'pool_hba.conf':
    ensure  => 'present',
    path    => "${pgpool2::params::confdir}/pool_hba.conf",
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => '0640',
    content => template('pgpool2/pool_hba.erb'),
    require => Package['pgpool2'],
    notify  => Exec['pgpoolreload'],
  }

  file { 'pool_passwd':
    ensure  => 'present',
    path    => "${pgpool2::params::confdir}/pool_passwd",
    owner   => $conf_group,
    group   => $conf_group,
    mode    => '0644',
    content => template('pgpool2/pool_passwd.erb'),
    require => Package['pgpool2'],
    notify  => Exec['pgpoolreload'],
  }

  file { '/etc/sudoers.d/pgpool':
    ensure => present,
    source => 'puppet:///modules/pgpool2/pgpool.sudoers',
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
  }

  file { 'pcp.conf':
    ensure  => 'present',
    path    => "${pgpool2::params::confdir}/pcp.conf",
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => '0640',
    require => Package['pgpool2'],
    notify  => Service['pgpool2'],
  }

  # Workaround for pgpool bug, see: http://postgresql.1045698.n5.nabble.com/pgpool-II-3-0-postgres-9rc1-md5-authentication-not-working-tp2839871p2839958.html
  # /etc/pgpool/pool_passwd doesn't work unless an empty /usr/local/etc/pool_passwd file exists
  file { '/usr/local/etc/pool_passwd':
    ensure => file,
    owner  => 'postgres',
    group  => 'postgres',
    mode   => '0444',
  }

  service { 'pgpool2':
    ensure     => running,
    name       => $pgpool2::params::service_name,
    enable     => true,
    hasrestart => true,
    require    => [
      File['pgpool.conf'],
      File['pcp.conf'],
    ],
  }

  exec { 'pgpoolreload':
    command     => '/etc/init.d/pgpool2 reload',
    refreshonly => true,
    require     => Package['pgpool2'],
    returns     => 3,
  }
}
