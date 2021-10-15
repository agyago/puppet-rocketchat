# Docker::Rocketchat

Rocket is an open-source communication. 
to learn more about rocketchat visit their github: https://github.com/RocketChat/Rocket.Chat

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rocketchat](#setup)
    * [What rocketchat affects](#what-rocketchat-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rocketchat](#beginning-with-rocketchat)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

Rocketchat provided a simple docker-compose file in their site but it is too open for me. Although this module is also a very basic setup using standalone MongoDB replicaSet cluster with Authentication, it could be a start.
All the certificates used here are self signed. You can provide your own by replacing the secret file.

## Setup
one gotcha here is to change SElinux to be permissive
```
# /opt/puppetlabs/bin/facter os.selinux
{
  config_mode => "enforcing",
  config_policy => "targeted",
  current_mode => "permissive",
  enabled => true,
  enforced => false,
  policy_version => "31"
}
```
or just type 'setenforce 0' before you run puppet agent

If not, you might experience permission denied errors like below:
```
Attaching to mongodb
mongodb       | find: '/data/db': Permission denied
mongodb       | chown: changing ownership of '/data/db': Permission denied
```

### Setup Requirements **OPTIONAL**

in order to use eyaml, you need to install or provide in your puppetfile -- voxpupuli/hiera-eyaml
To manual install, you can follow this => https://log-it.tech/2017/05/29/install-eyaml-module-on-puppet-master/

## Usage

just change the secrets.yml

# String (encrypting usernames)
  /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -s "string"
# Password (will get prompted to enter a string --encrypting passwords)
  /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -p
# Files (encrypting keys)
  /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -f $file

