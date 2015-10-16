class base_node() {

  class { 'apt': }

  # update packages before we install any
  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }
  Exec["apt-update"] -> Package <| |>

  # do not install recommended packages
  Package {
    install_options => ['--no-install-recommends'],
  }

  # list of base packages we deploy on every node
  package { [
    'byobu',
    'dstat',
    'git',
    'htop',
    'iputils-tracepath',
    'man-db',
    'mailutils',
    'mtr',
    'screen',
    'tcpdump',
    'tmux',
    'vim'
  ]:
    ensure => installed,
  }

  # install security updates
  # class { 'unattended_upgrades': }

  class { 'ntp': }
}

class vpn(
  $inet_dev='eth0',
  $ip_addr,
  $vpn_nr
) {
  apt::source { 'universe-factory':
    comment  => 'This repo includes a fastd release',
    location => 'http://repo.universe-factory.net/debian/',
    release  => 'jessie',
    repos    => 'main',
  }

  # install gateway packages
  package { ['bridge-utils', 'fastd', 'openvpn', 'batctl']:
    ensure => installed,
  }

  # fastd configuration
  file { '/etc/fastd/fastd.conf':
    ensure  => present,
    content => template('fastd.conf'),
    mode    => 755,
  }
}

node 'vpn2' {
  class { 'base_node': }

  class { 'vpn':
    ip_addr => '37.120.176.206',
    vpn_nr  => '2',
  }
}