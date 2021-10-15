# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include rocketchat

class rocketchat {
  ensure_packages(['docker','docker-compose','nginx'])

  $keyfile = lookup('rocketchat::keyfile')
  $servercert = lookup('rocketchat::servercert')
  $serverkey = lookup('rocketchat::serverkey')
  $user_account ={
    'initadmin'     => lookup('rocketchat::initadmin'),
    'initpaswd'     => lookup('rocketchat::initpaswd'),
    'admin_account' => lookup('rocketchat::admin_account'),
    'admin_pass'    => lookup('rocketchat::admin_pass'),
    'rock_user'     => lookup('rocketchat::rock_user'),
    'rock_paswd'    => lookup('rocketchat::rock_paswd'),
    'user_log'      => lookup('rocketchat::user_log'),
    'user_pass'     => lookup('rocketchat::user_pass'),
  }
  user { 'rocketchat':
    ensure  => present,
    comment => 'created by puppet',
    home    => '/home/rocketchat',
    system  => true,
    shell   => '/bin/bash';
  }

  file {
  '/home/rocketchat':
    ensure => directory,
    owner  => rocketchat,
    group  => rocketchat,
    mode   => '0700';

  ['/home/rocketchat/data','/home/rocketchat/data/mongodb']:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0755';

  '/home/rocketchat/Dockerfile':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0644',
    source  => 'puppet:///modules/rocketchat/Dockerfile',
    require => [
      File['/home/rocketchat'],
      File['/home/rocketchat/data/mongodb/init.sh'],
    ];

  '/home/rocketchat/data/mongodb/init.sh':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0755',
    content => epp('rocketchat/init.sh.epp',$user_account),
    require => File['/home/rocketchat/data/mongodb'];

  '/home/rocketchat/data/mongodb/mongodb-keyfile':
    ensure  => file,
    owner   => 999,
    mode    => '0600',
    content => epp('rocketchat/mongodb-keyfile.epp',{'keyfile'=>lookup('rocketchat::keyfile')}),
    require => File['/home/rocketchat/data/mongodb'];

  '/home/rocketchat/data/mongodb/mongod.conf':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0644',
    source  => 'puppet:///modules/rocketchat/mongod.conf',
    require => File['/home/rocketchat/data/mongodb'];

  '/etc/nginx/conf.d/rocketchat.conf':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0664',
    content => template('rocketchat/rocketchat.conf.erb'),
    notify  => Service['nginx'];

  '/etc/nginx/nginx.conf':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0664',
    source  => 'puppet:///modules/rocketchat/nginx.conf',
    notify  => Service['nginx'];

  '/home/rocketchat/docker-compose.yml':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0644',
    content => epp('rocketchat/docker-compose.yml.epp',$user_account),
    require => [
      File['/home/rocketchat'],
      File['/home/rocketchat/Dockerfile'],
      File['/home/rocketchat/data/mongodb/init.sh'],
      File['/home/rocketchat/data/mongodb/mongodb-keyfile'],
      File['/home/rocketchat/data/mongodb/mongod.conf'],
      File['/etc/systemd/system/rocketchat.service'],
    ],
    notify  => Service['rocketchat'];

  '/etc/ssl':
    ensure => directory,
    owner  => rocketchat,
    group  => rocketchat,
    mode   => '0664';

  '/etc/ssl/certificate.crt':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0664',
    content => epp('rocketchat/server.crt.epp',{'servercert'=>lookup('rocketchat::servercert')}),
    require => File['/etc/ssl'];

  '/etc/ssl/certificate.key':
    ensure  => file,
    owner   => rocketchat,
    group   => rocketchat,
    mode    => '0664',
    content => epp('rocketchat/server.key.epp',{'serverkey'=>lookup('rocketchat::serverkey')}),
    require => File['/etc/ssl'],
    notify  => Service['nginx'];

  '/etc/systemd/system/rocketchat.service':
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0755',
    source => 'puppet:///modules/rocketchat/rocketchat.service';

  }

  service {
    'docker':
      ensure  => running,
      enable  => true,
      require => Package['docker'];

    'nginx':
      ensure  => running,
      enable  => true,
      require => Package['nginx'];

    'rocketchat':
      ensure  => running,
      enable  => true,
      require => Service['docker'];
  }
}
