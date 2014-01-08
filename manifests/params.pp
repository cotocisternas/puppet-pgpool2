# == Class: pgpool2::params
#
# The pgpool2 configuration settings.
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
# === Authors
#
# Ingmar Steen <iksteen@gmail.com>
#
# === Copyright
#
# Copyright 2013 Ingmar Steen, unless otherwise noted.
# Heavily based on puppetlabs-postgresql.
#
class pgpool2::params(
  $custom_package_name   = undef,
  $custom_confdir        = undef,
  $custom_service_name   = undef,
  $custom_socket_dir     = undef,
  $custom_pcp_socket_dir = undef,
  $custom_pid_file_name  = undef,
  $custom_logdir         = undef,
) {
  case $::osfamily {
    'RedHat', 'Linux': {
      $package_name = pick($custom_package_name, 'postgresql-pgpool-II')
      $confdir = pick($custom_confdir, '/etc/pgpool-II')
      $service_name = pick($custom_service_name, 'pgpool')
      $socket_dir = pick($custom_socket_dir, '/tmp')
      $pcp_socket_dir = pick($custom_pcp_socket_dir, $socket_dir)
      $pid_file_name = pick($custom_pid_file_name, '/var/run/pgpool/pgpool.pid')
      $logdir = pick($custom_logdir, '/var/log/pgpool')
    }
    'Debian': {
      $package_name = pick($custom_package_name, 'pgpool2')
      $confdir = pick($custom_confdir, '/etc/pgpool2')
      $service_name = pick($custom_service_name, 'pgpool2')
      $socket_dir = pick($custom_socket_dir, '/run/postgresql')
      $pcp_socket_dir = pick($custom_pcp_socket_dir, $socket_dir)
      $pid_file_name = pick($custom_pid_file_name, '/run/postgresql/pgpool.pid')
      $logdir = pick($custom_logdir, '/var/log/postgresql')
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem ${::operatingsystem}, module ${module}")
    }
  }
}
