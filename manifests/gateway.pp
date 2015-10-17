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
    install_options => ['--no-install-recommends'],
  }

  # list of base packages we deploy on every node
  package { [
    'dstat',
    'git',
    'htop',
    'iputils-tracepath',
    'mtr',
    'tcpdump',
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

  class { 'vpn':
    ip_addr => '37.120.176.206',
    vpn_nr  => '2',
    secret_key => file('/root/fastd_secret_key')
  }
}