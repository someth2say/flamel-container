#!/bin/bash

# Builds from scratch (slower)
# using latest packages from the curriculum yum repository
podman build --no-cache -t flamel .

# Builds from scratch (slower)
# using specific packages from the curriculu yum repository
# older packages may not be available anymore
#podman build --build-arg CURRICULUM="-22-1" \
#  --build-arg BRANDING="-1.1.15" \
#  --build-arg FLAMEL="-2.1.18" \
#  --build-arg SLIDES="-1.2.0" \
#  --no-cache -t flamel .

# Speedier build, from cached layers
#podman build -t flamel .

# After building:
#skopeo copy containers-storage:localhost/flamel:latest docker://quay.io/flozanorht/flamel:0.3
# or
#podman push localhost/flamel:latest docker://quay.io/flozanorht/flamel:0.3
