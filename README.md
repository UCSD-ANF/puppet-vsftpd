# puppet-vsftpd

## Overview

This module enables and configures a vsftpd FTP server instance.

* `vsftpd` : Enable and configure the vsftpd FTP server

## Examples

With all of the module's default settings :

```puppet
include vsftpd
```

Tweaking a few settings (have a look at `manifests/init.pp` to know which
directives are supported as parameters) :

```puppet
class { 'vsftpd':
  anonymous_enable  => 'NO',
  write_enable      => 'YES',
  ftpd_banner       => 'Marmotte FTP Server',
  chroot_local_user => 'YES',
}
```

For any directives which aren't directly supported by the module, use the
additional `directives` hash parameter :

```puppet
class { 'vsftpd':
  ftpd_banner => 'ASCII FTP Server',
  directives  => {
    'ascii_download_enable' => 'YES',
    'ascii_upload_enable'   => 'YES',
  },
}
```

And if you really know what you are doing, you can use your own template or
start with an empty one which is provided (see `vsftpd.conf(5)`) in order
to have **all** configuration passed in the `directives` hash :

```puppet
class { 'vsftpd':
  template   => 'vsftpd/empty.conf.erb',
  directives => {
    'ftpd_banner'        => 'Upload FTP Server',
    'listen'             => 'YES',
    'tcp_wrappers'       => 'YES',
    'anon_upload_enable' => 'YES',
    'dirlist_enable'     => 'NO',
    'download_enable'    => 'NO',
  },
}
```

Example of adding _virtual users_ using hiera.  Note, using eyaml here to
encrypt passwords.  By enabling the _userlist_, we essentially whitelist the
users we want to allow.  In the example below only `myftpuser` will be
permitted.
```puppet
vsftpd::virtualuser_enable: true
vsftpd::anonymous_enable: 'NO'
vsftpd::write_enable: 'YES'
vsftpd::ftpd_banner: "Upload FTP Server"
vsftpd::chroot_local_user: 'YES'
vsftpd::userlist_enable: 'YES'
vsftpd::directives:
  allow_writeable_chroot: 'YES'
  guest_enable: 'YES'
  virtual_use_local_privs: 'YES'
vsftpd::user_list:
  - 'myftpuser'
vsftpd::virtual_users:
  myftpuser: ENC[PKCS7,MIIBeQYJKoZIhvcNAQcDoEANMBm6Lk3UApiAmjFcg9qm1VOV9lEvyiGQPxmmfQlg1uJ1YHJmBkVZdnj+3QUvCiopv0gtAxIIB+wotZbObB4Y+Sapq5CLK8LdYmGh5lD/0Y8PUhORVuQeYOpX+EJ2SDWAuhSG21TQdC1XrUHNRyKv3VKgmgBjIn02DM+Womki993xFA2VVmrTcKYiDdR7OmFEWpiiu7UChC0pXBofi1zUTG2fqIL43yuwg/GG0A95pvtg6R0sXZDxvtP8dmiiONfxM8qQS2PVwJMiWEMf9q+lWel6HVpF8lNf+M5h/dyjNk1eFi4yvYg4c8LVCXQ03jcPsyLeCvyLYEyKJxf2p/+ETA8BgkqhkiG9w0BBwEwHQYJYIZIAWUDBAEqBBAtiU1FZ+jccKeWuHPn55TlgBC8qZ2+29pxv7neoTrEERNw]
```

