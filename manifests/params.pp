# Class: vsftpd::params
#
class vsftpd::params {

  $confdir = $::osfamily ? {
    'Ubuntu' => '/etc',
    default  => '/etc/vsftpd'
  }

  $chroot_list_file    = "$confdir/chroot_list"
  $dbpkg_name          = [ 'db4-utils', 'db4' ]
  $package_name        = 'vsftpd'
  $pam_dir             = '/etc/pam.d'
  $service_name        = 'vsftpd'
  $userlist_file       = "$confdir/user_list"
  $virtualuser_file    = "$confdir/vusers.txt"

}

