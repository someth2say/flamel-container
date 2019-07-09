#!/bin/bash

sudo podman build -t flamel .

# After building:
#sudo skopeo copy containers-storage:localhost/flamel:latest docker://quay.io/flozanorht/flamel:0.1

