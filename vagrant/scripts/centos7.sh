#!/bin/bash

if [ ! -e /home/vagrant/.provision.txt ] ; then
    sudo rpm -ivh https://yum.puppet.com/puppet6-release-el-7.noarch.rpm
    sudo yum install -y puppet-agent
    touch /home/vagrant/.provision.txt
fi
