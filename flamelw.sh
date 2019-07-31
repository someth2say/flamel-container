#!/bin/bash

# Wrapper script for Windows, under Docker Toolbox v18.09.3
# Tested on Windows Home 10, updated as of July 15

#image=localhost/flamel
image=quay.io/flozanorht/flamel:0.2
container=testflamel

export LANG=en_US.utf-8

if ! docker inspect --type image --format '{{.Id}}' ${image} &>/dev/null
then
  echo -n "Downloading container image ${image}..."
  if docker pull ${image} &>/dev/null
  then
    echo "Done."   
  else
    echo "Failed!" 1>&2
    exit 127
  fi
fi

# Need to expose the project root to the container, not just the guides folder, to be able to fetch the git commit id

book=$(pwd)
if [ -r ${book}/publican-sg.cfg ]
then
  cd ..
  book=$(pwd)
fi


echo "Running containerized flamel with arguments '$@'..."
docker run --name ${container} -v ${book}:/tmp/coursebook ${image} "$@"
docker rm -f ${container} &>/dev/null

