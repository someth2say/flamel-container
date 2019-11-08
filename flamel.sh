#!/bin/bash

# This script was tested under RHEL8 CSB. You may require changes for other distros.

#image=localhost/flamel
image=quay.io/flozanorht/flamel:0.4
container=flamel
rootless=true

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


# Override ENTRYPOINT to not run flamel and run instead the check for package updates

if [ "$1" = "--check" ]
then
    podman run --name ${container} -q --rm --entrypoint /tmp/check-gls-packages.sh ${image} 
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
podman run --name ${container} -q --rm -v ${book}:/tmp/coursebook:z ${image} "$@"
status=$?

# non-rootless; Do not leave root files hanging around

if [ "$(id -u)" = "0" ] && [ -d ./guides/tmp ]
then
  echo "Changing owner of tmp files to $(id -un ${SAVED_UID}):$(id -gn ${SAVED_GID})..."
  chown -R ${SAVED_UID}:${SAVED_GID} ./guides/tmp
fi

exit "${status}"
