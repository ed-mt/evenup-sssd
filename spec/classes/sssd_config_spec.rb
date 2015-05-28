require 'spec_helper'

describe 'sssd', :type => :class do
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :disposition => 'prod' } }
  let(:params) { {
    :filter_groups      => 'root',
    :filter_users       => 'root,wheel',
    :ldap_base          => 'dc=example,dc=org',
    :ldap_uri           => 'ldap://ldap.example.org',
    :ldap_access_filter => '(&(objectclass=shadowaccount)(objectclass=posixaccount))',
    :ldap_tls_reqcert   => 'demand',
    :ldap_tls_cacert    => '/etc/pki/tls/certs/ca-bundle.crt',
  } }

  it { should create_class('sssd::config') }

  it { should contain_file('/etc/sssd/sssd.conf').with_mode('0600') }
  it { should contain_file('/etc/nsswitch.conf') }
  it { should contain_file('/etc/pam.d/password-auth').with(:source => 'puppet:///modules/sssd/password-auth') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_LDAP.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_pam.log') }
  it { should_not contain_beaver__stanza('/var/log/sssd/sssd_nss.log') }

  context 'setting enumerate off' do
    let(:params) { { :ldap_enumerate => false } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/enumerate = false/)}
  end

  context 'setting enumerate on' do
    let(:params) { { :ldap_enumerate => true } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/enumerate = true/)}
  end

  context 'setting ldap_pwd_policy' do
    let(:params) { { :ldap_pwd_policy => 'none' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_pwd_policy = none/)}
  end

  context 'setting filter_groups' do
    let(:params) { { :filter_groups => 'foo,bar' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/filter_groups = foo,bar/)}
  end

  context 'setting filter_users' do
    let(:params) { { :filter_users => 'bob,john' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/filter_users = bob,john/)}
  end

  context 'setting ldap_base' do
    let(:params) { { :ldap_base => 'dc=company,dc=com' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_search_base = dc=company,dc=com/)}
  end

  context 'setting ldap_uri' do
    let(:params) { { :ldap_uri => 'ldap://ldap.company.com' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_uri = ldap:\/\/ldap.company.com/)}
  end

  context 'setting ldap_access_filter' do
    let(:params) { { :ldap_access_filter => 'objectclass=posixaccount' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_access_filter = objectclass=posixaccount/)}
  end

  context 'setting ldap_group_member' do
    let(:params) { { :ldap_group_member => 'memberUid' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_group_member = memberUid/)}
  end

  context 'setting ldap_tls_reqcert' do
    let(:params) { { :ldap_tls_reqcert => 'always' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_tls_reqcert = always/)}
  end

  context 'setting ldap_tls_cacert' do
    let(:params) { { :ldap_tls_cacert => '/tmp/cert' } }
    it { should contain_file('/etc/sssd/sssd.conf').with_content(/ldap_tls_cacert = \/tmp\/cert/)}
  end

  context 'setting manage_nsswitch' do
    let(:params) { { :manage_nsswitch => false } }
    it { should_not contain_file('/etc/nsswitch.conf') }
  end

  context 'centos 6' do
    let(:facts) { { :operatingsystemrelease => '6.6' } }
    it { should contain_file('/etc/pam.d/system-auth').with(:source => 'puppet:///modules/sssd/system-auth') }
  end

  context 'centos 7' do
    let(:facts) { { :operatingsystemrelease => '7.0.1406' } }
    it { should contain_file('/etc/pam.d/system-auth').with(:source => 'puppet:///modules/sssd/system-auth.oddjob') }
  end

  context 'with beaver' do
    let(:params) { { :logsagent => 'beaver' } }

    it { should contain_beaver__stanza('/var/log/sssd/sssd_LDAP.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd_pam.log') }
    it { should contain_beaver__stanza('/var/log/sssd/sssd_nss.log') }
  end

end
