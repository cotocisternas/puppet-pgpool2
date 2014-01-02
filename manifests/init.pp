# == Class: pgpool2
#
# Puppet (3.x) module for setting up pgpool-II PostgreSQL clusters
# This is a fork of the unmaintained iksteen/puppet-pgpool2 module
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
#    backend_port        => 5432,
#    listen_addresses    => '*',
#    replication_mode    => true,
#
#    # Logging configuration
#    load_balance_mode   => true,
#    log_destination     => 'syslog',
#    log_connections     => true,
#    log_hostname        => true,
#    debug_level         => 1,
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
  # OTHERS
  $relcache_expire                      = 0,
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

  file { 'pcp.conf':
    ensure  => 'present',
    path    => "${pgpool2::params::confdir}/pcp.conf",
    owner   => $conf_owner,
    group   => $conf_group,
    mode    => '0640',
    require => Package['pgpool2'],
    notify  => Service['pgpool2'],
  }

  service { 'pgpool2':
    ensure  => running,
    name    => $pgpool2::params::service_name,
    enable  => true,
    require => [
      File['pgpool.conf'],
      File['pcp.conf'],
    ],
  }
}
