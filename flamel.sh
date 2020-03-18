#!/bin/bash

# This script was tested under RHEL8 CSB. You may require changes for other distros.

tag=latest
#image=localhost/flamel
image=quay.io/flozanorht/flamel
container=flamel
rootless=true

# DNS options for Red Hat VPN using RDU2
#DNSOPTS="--dns-search redhat.com --dns 10.11.5.19 --dns 10.5.30.160"

# Usage nessage

if [ "$1" = "--help" -o "$1" = "-h" ]
then
  echo "Wrapper script to run the containerized flamel."
  echo
  echo "Usage: $0 {options|target}"
  echo
  echo -e "\t 'target' is a target to flamel such as 'sg', 'ig', 'slides', and 'clean'"
  echo -e "\t 'options' can be:"
  echo -e "\t --tag arg to use tag 'arg' instead of 'latest' for the container image."
  echo -e "\t --check to check if the main packages inside the container image, such as redhat-training-xsl, are on their latest releases."
  echo -e "\t --purge to remove local container images, allowing pulling of an updated image."
  echo
  echo "The beggining of this script also defines a few variables that you may change as your local configuration."
  exit
fi

# Rootless tested under RHEL 8.0 CSB but should work on any RHEL 8+ and Fedora 30+.
# Hint: there should be no need to configure uid and gid maps anymore.

if ! ${rootless}
then
  if [ "$(id -u)" != "0" ]
  then
    sudo $0 "$(id -u)" "$(id -g)" "$@"
    exit $?
  fi
fi

# Non-rootless: Saving the uid and gid to change file ownership after running the container

if [ "$(id -u)" = "0" ]
then
  SAVED_UID=$1
  SAVED_GID=$2
  shift ; shift
fi

export LANG=en_US.utf-8

# Allow overriding the image tag

if [ "$1" = "--tag" ]
then
  if [ "$2" = "" ]
  then
    echo "Missing tag argument" 1>&2
    exit 127
  fi
  tag="$2"
  shift ; shift
fi

# Remove local container image (to later pull an updated image)

if [ "$1" = "--purge" ]
then
  echo -n "Removing local container image ${image}:${tag}..."
  if podman rmi --force ${image}:${tag} 
  then
    echo "Done."
    exit
  else
    echo "Failed!" 1>&2
    exit 127
  fi
fi

# Pull the container image if not available locally

if ! podman inspect --type image --format '{{.Id}}' ${image}:${tag} &>/dev/null
then
  echo -n "Downloading container image ${image}:${tag}..."
  if podman pull ${image}:${tag} &>/dev/null
  then
    echo "Done."   
  else
    echo "Failed!" 1>&2
    exit 127
  fi
fi


# Override ENTRYPOINT to not run flamel and run instead the check for package updates

if [ "$1" = "--check" ]
then
    podman run ${DNSOPTS} --name ${container} -q --rm --entrypoint /tmp/check-gls-packages.sh ${image}:${tag} 
    exit $?
fi

# Need to expose the project root to the container, not just the guides folder, to be able to fetch the git commit id

book=$(pwd)
if [ -r ${book}/publican-sg.cfg ]
then
  cd ..
  book=$(pwd)
fi

echo "Adding SELinux label to book files..."
chcon -Rt svirt_sandbox_file_t ${book}

echo "Running containerized flamel with arguments '$@'..."
podman run --name ${container} -q --rm -v ${book}:/tmp/coursebook:z ${image}:${tag} "$@"
status=$?

# non-rootless; Do not leave root files hanging around

if [ "$(id -u)" = "0" ] && [ -d ./guides/tmp ]
then
  echo "Changing owner of tmp files to $(id -un ${SAVED_UID}):$(id -gn ${SAVED_GID})..."
  chown -R ${SAVED_UID}:${SAVED_GID} ./guides/tmp
fi

exit "${status}"
