require 'spec_helper'

describe 'vsftpd' do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile }
      it { is_expected.to contain_class('vsftpd') }
      it { is_expected.to contain_class('vsftpd::params') }
      it { is_expected.to contain_package('vsftpd') }
      it { is_expected.to contain_service('vsftpd') }

      case facts[:osfamily]
      when 'RedHat'
        it { is_expected.to contain_file('/etc/vsftpd/vsftpd.conf')
          .that_notifies('Service[vsftpd]') }

        context 'virtualuser enabled' do
          let(:params) { {'virtualuser_enable' => true} }

          ['db4-utils', 'db4'].each do |pkg|
            it { is_expected.to contain_package(pkg) }
          end
          it { is_expected.to contain_file('/etc/pam.d/vsftpd_virtual')
            .with( :ensure => 'present' ) }
        end
      when 'Debian'
        it { is_expected.to contain_file('/etc/vsftpd.conf')
          .that_notifies('Service[vsftpd]') }

        context 'virtualuser enabled' do
          let(:params) { {'virtualuser_enable' => true} }

          it { is_expected.to contain_package('db4.2-util') }
          it { is_expected.to contain_file('/etc/pam.d/vsftpd_virtual')
            .with( :ensure => 'present' ) }
        end
      end
    end
  end

end
