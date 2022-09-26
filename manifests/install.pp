# Install dns service
# @api private
class dns::install {
  if ! empty($dns::dns_server_package) {
    ensure_packages([$dns::dns_server_package])
    $pkg_req = Package[$dns::dns_server_package]
  } else {
    $pkg_req = undef
  }

  if $dns::group_manage {
    group { $dns::group:
      require => $pkg_req,
    }
  }

  if $facts['os']['family'] in ['Debian', 'RedHat'] {
    if $dns::redhat_scl {
      ['dig', 'nsupdate'].each | $util | {
        file { "/usr/bin/${util}":
          ensure  => file,
          owner   => root,
          group   => root,
          mode    => '0755',
          content => [
            '#!/bin/bash',
            "scl enable isc-bind -- ${util} $@"
          ]
        }
      }

      file { "${localzonepath}":
        owner   => root,
        group   => root,
        mode    => '0755',
        content => template('dns/named.rfc1912.zones.erb'),
      }
    }
  }
}
