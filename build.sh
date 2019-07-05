#!/bin/bash

sudo podman build -t flamel .

# After building:
#sudo skopeo copy containers-storage:localhost/flamel docker://quay.io/flozanorht/flamel

