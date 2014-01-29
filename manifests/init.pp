# == Class: appsvn
#
# Full description of class appsvn here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { appsvn:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class appsvn (
  $public_key,
  $private_key,
  $key_base_name = 'appsvn',
  $protocol      = 'http',
  $user          = 'svnuser',
  $server        = "svn.${::domain}",
  $base_path     = "/x01/svn/hjapps",
  $branch        = 'trunk',
) {

  # validate $server
  $server_is_ip_address  = is_ip_address($server)
  $server_is_domain_name = is_domain_name($server)

  if ($server_is_ip_address == false) and ($server_is_domain_name == false) {
    fail("server <${server}> must be a valid IP address or host name")
  }

  # validate protocol
  validate_re($protocol, '^(http|https|svn|svn\+ssh)$', "appsvn::protocol <${protocol}> does not match regex")

  # include ssh class if the protocol is svn+ssh. This class will ensure ssh is
  # setup and allows for the specification of the contents of root's
  # ~/.ssh/config
  if $protocol == 'svn+ssh' {
    include ssh
  }

  # validate $user
  validate_re($user, '^[a-z][-a-z0-9]*$', "appsvn::user <${user}> does not match regex")

  # validate $public_key
  validate_re($public_key, '^ssh-(rsa|dsa).*', "appsvn::public_key <${public_key}> does not match regex")

  # validate $branch
  validate_re($branch, '^([^\/\0]+(\/)?)+$', "appsvn::branch <${branch}> does not match regex")

  file { 'appsvn_public_key':
    ensure  => file,
    content => $public_key,
    path    => "${::root_home}/.ssh/${key_base_name}.pub",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

  file { 'appsvn_private_key':
    ensure  => file,
    content => $private_key,
    path    => "${::root_home}/.ssh/${key_base_name}",
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
  }

}
