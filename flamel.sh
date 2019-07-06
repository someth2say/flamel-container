#!/bin/bash

# This script was tested under RHEL8 CSB. You may require changes for other distros.

#image=localhost/flamel
image=quay.io/flozanorht/flamel
container=testflamel

#XXX Hack until I learn how to run podman rootless

if [ "$(id -u)" != "0" ]
then
  sudo $0 "$@"
  exit $?
fi

export LANG=en_US.utf-8

if ! podman inspect --type image --format '{{.Id}}' ${image} &>/dev/null
then
  echo -n "Downloading container image ${image}..."
  if podman pull ${image} &>/dev/null
  then
    echo "Done."   
  else
    echo "Failed!" 1>&2
    exit 127
  fi
fi

echo "Adding SELinux label to book files..."
book=$(pwd)
chcon -Rt svirt_sandbox_file_t ${book}

#XXX Another hack, flamel sg inside the container cannot clean these files
rm -rf ./tmp

echo "Running containerized flamel..."
podman run --name ${container} -q -rm -v ${book}:/tmp/coursebook ${image}

