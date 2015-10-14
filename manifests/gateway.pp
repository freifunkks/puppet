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
  class { 'unattended_upgrades': }

  class { 'ntp': }
}

node 'vpn2' {
  class { 'base_node': }

  exec { "add-fastd":
    command => 'echo "deb http://repo.universe-factory.net/debian/ jessie main" > /etc/apt/sources.list.d/universe.list'
  }

  exec { 'apt-update': }

  package { ['bridge-utils', 'fastd', 'openvpn']:
    ensure => installed,
  }
}