# pgpool2 puppet module

Puppet (3.x) module for setting up pgpool-II PostgreSQL clusters.

This is a fork of the unmaintained iksteen/puppet-pgpool2 module.

# Examples
```
 class { pgpool2:

   backends              => [
     {
       'hostname'        => 'db-server-01',
       'weight'          => 1,
       'data_directory'  => '/data',
       'flag'            => 'ALLOW_TO_FAILOVER',
     },

     {
       'hostname'        => 'db-server-02',
       'weight'          => 1,
       'data_directory'  => '/data',
       'flag'            => 'ALLOW_TO_FAILOVER',
     }
   ],

   pgclients             =>
     {
       'my-web-server'   => '192.168.0.100/32',
     },

   backend_port        => 5432,
   listen_addresses    => '*',
   replication_mode    => true,

   # Logging configuration
   load_balance_mode   => true,
   log_destination     => 'syslog',
   log_connections     => true,
   log_hostname        => true,
   debug_level         => 1,

 }
```
# Authors

Author Name Sam McLeod
