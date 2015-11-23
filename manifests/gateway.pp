class base_node() {

  Service {
    provider => systemd,
  }

  class { 'apt': }

  # update packages before we install any
  exec { "apt-update":
    command => "/usr/bin/apt-get update"
  }
  Exec["apt-update"] -> Package <| |>

  # do not install recommended packages
  Package {
    install_options => ['--no-install-recommends', '--force-yes'],
  }

  # list of base packages we deploy on every node
  package { [
    'dstat',
    'git',
    'htop',
    'iputils-tracepath',
    'mtr',
    'tcpdump',
    'vim',
    'vnstat',
    'vnstati'
  ]:
    ensure => installed,
  }

  # install security updates
  class { 'unattended_upgrades': }

  class { 'ntp': }

  service { 'vnstat':
    ensure   => running,
    provider => init,
    enable   => true
  }
}

node 'vpn2' {
  class { 'base_node': }

  class { 'vpn':
    ip_addr => '37.120.176.206',
    ip_mask => '22',
    ip_gtw  => '37.120.176.1',
    ip_brd  => '37.120.176.0',
    vpn_nr  => '2'
  }
}
