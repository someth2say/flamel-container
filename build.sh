#!/bin/bash

#podman build -t flamel .
podman build --no-cache -t flamel .

# After building:
# skopeo copy containers-storage:localhost/flamel:latest docker://quay.io/flozanorht/flamel:0.2

