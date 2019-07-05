#!/bin/bash

# This script was tested under RHEL8 CSB. You may require changes for other distros.

#image=localhost/flamel
image=quay.io/flozanorht/flamel
container=testflamel

export LANG=en_US.utf-8

#if ! sudo podman inspect --type image --format '{{.Id}}' ${image} &>/dev/null
#then
#  echo -n "Downloading container image ${image}..."
#  if sudo podman pull ${image} &>/dev/null
#  then
#    echo "Done."   
#  else
#    echo "Failed!" 1>&2
#    exit 127
#  fi
#fi

echo "Adding SELinux label to book files..."
book=$(pwd)
sudo chcon -Rt svirt_sandbox_file_t ${book}

sudo rm -rf ./tmp
#if [ -d ./tmp ]
#then
#    sudo chcon -Rt svirt_sandbox_file_t ./tmp
#fi

echo "Running containerized flamel..."
sudo podman run --name ${container} -q -rm -v ${book}:/tmp/coursebook ${image}

