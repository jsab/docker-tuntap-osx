#!/bin/bash

SCRIPT_DIR="$(dirname $0)"

echo "Creating resolver file..."
sudo mkdir /etc/resolver
sudo sh -c 'echo "nameserver 127.0.0.1\nport 5300" > /etc/resolver/docker'

echo "Installing tap..."
${SCRIPT_DIR}/sbin/docker_tap_install.sh -f

echo -n "Waiting for docker to restart"
DOCKER_INFO=1
while [[ $DOCKER_INFO -ne "0" ]]; do

	echo -n .
	docker info &> /dev/null
	DOCKER_INFO=$?
	sleep 1

done;
echo done!

echo "Starting tap..."
${SCRIPT_DIR}/sbin/docker_tap_up.sh

echo "Adding route..."
sudo route add -net 172.17.0.0 -netmask 255.255.0.0 10.0.75.2

echo "Running DNS server..."
docker run --rm --name devdns -p 5300:53/udp -e DNS_DOMAIN=docker -v /var/run/docker.sock:/var/run/docker.sock --rm ruudud/devdns
