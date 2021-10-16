# Docker::Rocketchat Server

Rocket is an open-source communication. 
to learn more about rocketchat visit their github: https://github.com/RocketChat/Rocket.Chat

For Desktop apps, it can be downloaded here: https://rocket.chat/download

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rocketchat](#setup)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)


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
```
just change the secrets.yml

to encrypt:
# String (encrypting usernames)
  /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -s "string"
# Password (will get prompted to enter a string --encrypting passwords)
  /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -p
# Files (encrypting keys)
  /usr/local/bin/eyaml encrypt --pkcs7-public-key=/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem -o string -f $file
```
after replacing secrets, run 'puppet agent -t'
```
# check rocketchat service

$ systemctl status rocketchat
● rocketchat.service - Rocketchat
   Loaded: loaded (/etc/systemd/system/rocketchat.service; enabled; vendor preset: disabled)
   Active: active (exited) since Sat 2021-10-16 04:58:09 UTC; 2h 29min ago
  Process: 2085 ExecStart=/usr/bin/docker-compose up -d (code=exited, status=0/SUCCESS)
 Main PID: 2085 (code=exited, status=0/SUCCESS)
    Tasks: 0
   Memory: 0B
   CGroup: /system.slice/rocketchat.service

Oct 16 04:58:09 rocketchat1.mylabserver.com systemd[1]: Started Rocketchat.

# check docker if status are up

CONTAINER ID        IMAGE                COMMAND                  CREATED              STATUS                        PORTS                      NAMES
dcab23c4913d        rocket.chat:latest   "node main.js"           About a minute ago   Up About a minute             0.0.0.0:3000->3000/tcp     rocket.chat
c508e75231f0        rocketchat_mongo     "docker-entrypoint..."   About a minute ago   Up About a minute (healthy)   0.0.0.0:27017->27017/tcp   mongodb
```
if all are good and running.

Start to configure the server through browser - https://yourserverhostname

