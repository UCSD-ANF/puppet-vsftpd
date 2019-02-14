# Class: vsftpd::params
#
class vsftpd::params {

  $confdir = $::osfamily ? {
    'Debian' => '/etc',
    default  => '/etc/vsftpd'
  }

  $dbpkg_name = $::osfamily ? {
    'Debian' => [ 'db4.2-util' ],
    default  => [ 'db4-utils', 'db4' ]
  }

  $chroot_list_file    = "$confdir/chroot_list"
  $package_name        = 'vsftpd'
  $pam_dir             = '/etc/pam.d'
  $service_name        = 'vsftpd'
  $userlist_file       = "$confdir/user_list"
  $virtualuser_file    = "$confdir/vusers.txt"

}

