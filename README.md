# Containerized Flamel for Red Hat Training Books and Slides

### 2019-07-30 UPDATE

Prebuilt image tag 0.2 is updated with redhat-training-xsl-v1.1.15, flamel-2.1.18, and reveal-js-slide-generator 1.2.0.

Rootless mode is now the default. Change the rootless variable inside the script to revert to the old behavior using sudo.

New env vars BRANDING, FLAMEL, and SLIDES to make it easy to check which releases are included into the pre-built container image using skopeo or podman inspect, without the need to create a container. Also new env var CURRICULUM for the release of the curriculum-release package.

New flamelw.sh script that uses Docker tools, tested on a Windows 10 Home machine.

### 2019-07-10 UPDATE

The wrapper script was tested rootless in RHEL 8 CSB and works fine.

### 2019-07-09 UPDATE

Now the container and wrapper script take command-line arguments to flamel. It is not hardcoded to 'flamel sg' anymore. You can do 'flamel.sh sg', 'flamel.sh ig' etc. Image tag '0.1' contains this update, 'latest' remains hardcoded to 'flamel sg'.

## Introduction

This Dockerfile builds a Fedora-based container for flamel, with the GLS branding and customizations, in the hope you can use it to build student guide and instructor guide PDF books and also HTML5 slides on any Linux distro and, who knows, even MacOS. (I don't think there are any Windows users in the GLS team).

It is a very basic container image, based on Fedora 30. The magic is on the flamel.sh wrapper script, that mounts the current working dir as a volume in the container, with podman options that allow the host folder to be shared by multiple containers, and sets SELinux labels on the host folder so it can be shared between the host and a container.

A pre-built container image is available at quay.io/flozanorht/flamel as a public image. I should probably move it into a private repo that only the GLS team can access. Or maybe only a GLS-owned namespace that we could give access to outside contractors.

The Dockerfile was verified against Steve's playboks at https://github.com/RedHatTraining/curriculum-build-setup and installs the same packages. Some configurations performed by these playbooks, such as locking releases for flamel, are not necessary in a container image because these are never updated, they are always re-created from scratch.

## Usage

Copy the script to a folder in your path, such as ~/bin, and run the script from your guides folder, just like you would do with an RPM-based installation of flamel. Optionally rename the script from 'flamel.sh' to just 'flamel' so it works as a true drop-in replacement, including being used by pre-commit.

The script uses podman as the current user (rootless), for the benefit of RHEL 8 users. RHEL 7 users need sudo, just change a variable in the beginning of the script. Generating slides also works. Rootless should work with either RHEL 8+ and Fedora 30+.

If your distro is not RHEL, CentOS, nor Fedora, but provides podman, it should work too, at least using sudo (rootless=false). You can also try to adapt the flamel.sh script to use docker community and your distro security settings (I hope you won't just disable SElinux).

Please ask any questions to Fernando Lozano <flozano@redhat.com> or on the #curriculum-core room on Google Chat.

## PENDING

Tests using instructor guide.

CI/CD updates of the container image with new flamel, branding, or slides packages, maybe using Quay.io build support.

