#!/bin/bash

# This script was tested under RHEL8 CSB. You may require changes for other distros.

#image=localhost/flamel
image=quay.io/flozanorht/flamel:0.3
container=flamel
rootless=true

if podman &> /dev/null;
then
  echo "Using PODMAN as container runtime"
  runtime=podman
  runtine_run_params="-q --rm"
elif docker &> /dev/null; 
then
  echo "Using DOCKER as container runtime"
  runtime=docker
  runtine_run_params="--rm"
else 
  echo "No container runtime found"
  exit -1
fi

#runtime=${runtime}
runtime=docker
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

if ! ${runtime} inspect --type image --format '{{.Id}}' ${image} &>/dev/null
then
  echo -n "Downloading container image ${image}..."
  if ${runtime} pull ${image} &>/dev/null
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
    ${runtime} run --name ${container} ${runtine_run_params} --entrypoint /tmp/check-gls-packages.sh ${image} 
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
chcon -Rt svirt_sandbox_file_t ${book} &> /dev/null

echo "Running containerized flamel with arguments '$@'..."
${runtime} run --name ${container} ${runtine_run_params} -v ${book}:/tmp/coursebook:z ${image} "$@"
status=$?

# non-rootless; Do not leave root files hanging around

if [ "$(id -u)" = "0" ] && [ -d ./guides/tmp ]
then
  echo "Changing owner of tmp files to $(id -un ${SAVED_UID}):$(id -gn ${SAVED_GID})..."
  chown -R ${SAVED_UID}:${SAVED_GID} ./guides/tmp
fi

exit "${status}"
