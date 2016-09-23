#!/bin/bash
#log
echo $@ >> /tmp/policy.log
#disallow puppetserver start via dpkg
if [[ "$1" == "puppetserver" && "$2" == "start" ]] ; then exit 2
fi
echo "exited 0" >> /tmp/policy.log
exit 0
