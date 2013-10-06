#!/bin/bash
cd /tmp
wget -q http://apt.puppetlabs.com/puppetlabs-release-precise.deb
sleep 5
dpkg -i puppetlabs-release-precise.deb
