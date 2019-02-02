# Class: vsftpd
#
# Install, enable and configure a vsftpd FTP server instance.
#
# Parameters:
#  see vsftpd.conf(5) for details about what the available parameters do.
# Sample Usage :
#  include vsftpd
#  class { 'vsftpd':
#    anonymous_enable  => 'NO',
#    write_enable      => 'YES',
#    ftpd_banner       => 'Marmotte FTP Server',
#    chroot_local_user => 'YES',
#  }
#
class vsftpd (
  String             $confdir                 = $::vsftpd::params::confdir,
  Array              $dbpkg_name              = $::vsftpd::params::dbpkg_name,
  String             $package_name            = $::vsftpd::params::package_name,
  String             $service_name            = $::vsftpd::params::service_name,
  String             $pam_dir                 = $::vsftpd::params::pam_dir,
  Optional[Array]    $user_list               = [],
  Boolean            $virtualuser_enable      = false,
  Optional[Hash]     $virtual_users           = {},
  String             $virtualuser_file        = $::vsftpd::params::virtualuser_file,
  String             $template                = 'vsftpd/vsftpd.conf.erb',
  # vsftpd.conf options
  Enum['YES', 'NO']  $anonymous_enable        = 'YES',
  Enum['YES', 'NO']  $local_enable            = 'YES',
  Enum['YES', 'NO']  $write_enable            = 'YES',
  String             $local_umask             = '022',
  Enum['YES', 'NO']  $anon_upload_enable      = 'NO',
  Enum['YES', 'NO']  $anon_mkdir_write_enable = 'NO',
  Enum['YES', 'NO']  $dirmessage_enable       = 'YES',
  Enum['YES', 'NO']  $xferlog_enable          = 'YES',
  Enum['YES', 'NO']  $connect_from_port_20    = 'YES',
  Enum['YES', 'NO']  $chown_uploads           = 'NO',
  Optional[String]   $chown_username          = undef,
  String             $xferlog_file            = '/var/log/vsftpd.log',
  Enum['YES', 'NO']  $xferlog_std_format      = 'YES',
  String             $idle_session_timeout    = '600',
  String             $data_connection_timeout = '120',
  Optional[String]   $nopriv_user             = undef,
  Enum['YES', 'NO']  $async_abor_enable       = 'NO',
  Enum['YES', 'NO']  $ascii_upload_enable     = 'NO',
  Enum['YES', 'NO']  $ascii_download_enable   = 'NO',
  Optional[String]   $ftpd_banner             = undef,
  Enum['YES', 'NO']  $chroot_local_user       = 'NO',
  Enum['YES', 'NO']  $chroot_list_enable      = 'NO',
  String             $chroot_list_file        = $::vsftpd::params::chroot_list_file,
  Enum['YES', 'NO']  $ls_recurse_enable       = 'NO',
  Enum['YES', 'NO']  $listen                  = 'YES',
  Optional[Integer]  $listen_port             = undef,
  Enum['YES', 'NO']  $userlist_enable         = 'YES',
  Optional[Enum['YES','NO']] 
                     $userlist_deny           = undef,
  String             $userlist_file           = $::vsftpd::params::userlist_file,
  Enum['YES', 'NO']  $tcp_wrappers            = 'YES',
  Optional[String]   $hide_file               = undef,
  Enum['YES', 'NO']  $hide_ids                = 'NO',
  Enum['YES', 'NO']  $setproctitle_enable     = 'NO',
  Enum['YES', 'NO']  $text_userdb_names       = 'NO',
  Optional[Integer]  $max_clients             = undef,
  Optional[Integer]  $max_per_ip              = undef,
  Optional[Integer]  $pasv_min_port           = undef,
  Optional[Integer]  $pasv_max_port           = undef,
  Optional[String]   $ftp_username            = undef,
  Optional[String]   $banner_file             = undef,
  Optional[Enum['YES','NO']] 
                     $allow_writeable_chroot  = undef,
  Optional[Hash]     $directives              = {},
) inherits ::vsftpd::params {
 
  package { $package_name: ensure => installed }


  if $virtualuser_enable {
    package { $dbpkg_name: ensure => installed }

    $pam_service_name = 'vsftpd_virtual'
    $virtualuser_db = "$confdir/virtual_users.db"

    file { "$pam_dir/vsftpd_virtual": 
      ensure    => 'present',
      content   => template('vsftpd/vsftpd_virtual.erb')
    }

    if !empty($virtual_users) {
      file { $virtualuser_file :
        ensure    => 'present',
        mode      => '0600',
        owner     => 'root',
        group     => 'root',
        content   => template('vsftpd/vuser_list.txt.erb'),
        require   => Package[$dbpkg_name],
        notify    => Exec["db_load_users"],
      }

      exec {"db_load_users":
        require   => File[$virtualuser_file],
        path    => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        command   => "db_load -T -t hash -f $virtualuser_file $virtualuser_db",
        refreshonly => true,
      }
    }
  } else {

    $pam_service_name = 'vsftpd'

  }

  service { $service_name:
    require   => Package[$package_name],
    enable    => true,
    ensure    => running,
    hasstatus => true,
  }

  file { "${confdir}/vsftpd.conf":
    require => Package[$package_name],
    content => template($template),
    notify  => Service[$service_name],
  }

  if !empty($user_list) {
    file { $userlist_file :
      ensure    => 'present',
      content   => template('vsftpd/user_list.erb'),
      notify    => Service[$service_name]
    }
  }

  
}

