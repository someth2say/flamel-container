#!/bin/bash

# This script was tested under RHEL8 CSB. You may require changes for other distros.

image=quay.io/flozanorht/flamel
container=testflamel

book=$(pwd)
sudo chcon -Rt svirt_sandbox_file_t ${book}
sudo podman run --name $container -q -rm -v ${book}:/tmp/coursebook $image

