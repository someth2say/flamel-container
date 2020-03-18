# Containerized Flamel for Building Red Hat Training Books and Slides

### 2020-03-18 UPDATE

Prebuilt image tag 0.3 (also 0.3-6 and latest) updated with flamel 2.2.1-1, redhat-training-xsl 1.1.18-1, publican-gls-redhat-new 0.7.2.1 and reveal-js-slide-generator 1.2.3-1.
This image also includes the fixes to --check from this and the previous updates.

Fixed a bug displaying colored error messages on --check

Added the DNSOPTS variable to the wrapper script to allow configuring a workaround for the DNS issues explained in Caveats.

The flamelw.sh wrapper script for Windows and Mac is lagging behind the flamel.sh script for RHEL and other distros with podman. I need help syncing them and testing the changes on Mac and Windows.

### 2020-03-17 UPDATE

Updated the --check option to check the IG branding package also.

Added a CAVEATS heading to this README file.

## Introduction

This Dockerfile builds a Fedora-based container for flamel, with the GLS branding and customizations, in the hope you can use it to build student guide and instructor guide PDF books and also HTML5 slides on any Linux distro and also  MacOS and Windows.

It is a very basic container image, based on Fedora 30. The magic is on the flamel.sh wrapper script, that mounts the current working dir as a volume in the container, using podman options that allow the host folder to be shared by multiple containers, and sets SELinux labels on the host folder so it can be shared between the host and a container.

A pre-built container image is available at quay.io/flozanorht/flamel as a public image. I should probably move it into a private repo that only the GLS team can access. Or maybe only a GLS-owned namespace that we could give access to outside contractors.

The Dockerfile was verified against Steve's playboks at https://github.com/RedHatTraining/curriculum-build-setup and installs the same packages. Some configurations performed by these playbooks, such as locking releases for flamel, are not necessary in a container image because these are never updated, they are always re-created from scratch.

## Usage

Copy the flamel.sh wrapper script to a folder in your path, such as ~/bin, and run the script from your guides folder, just like you would do with an RPM-based installation of flamel. Optionally rename the script from 'flamel.sh' to just 'flamel' so it works as a true drop-in replacement, including being invoked by pre-commit.

### Options

If you think the container image cached into your system contains outdated curriculum packages, connect to the VPN and run the wrapper script with the **--check** option. It will check the latest packages on the curriculum repo and compare with the versions of the same packages inside the container. If you have no access to the VPN, the --check option just prints the versions of the packages inside the container.

If you verify that your local image contains outdated packages, use the **--purge** option to remove the local image. The next time you run the wrapper script it downloads the latest container image.

Most options can be combined with the **--tag** option to specify an image tag other than 'latest'. This allows running multiple flamel container images side-by-side, for example to compare the outputs from different releases.

### Alternative Wrapper Script

The flamel.sh wrapper script uses podman as the current user (rootless), for the benefit of RHEL 8 users. RHEL 7 users need sudo, just change a variable in the beginning of the script. Generating slides also works. Rootless should work with either RHEL 8+ and Fedora 30+.

If your distro is not RHEL, CentOS, nor Fedora, but provides podman, it should work too, at least using sudo (rootless=false).

You can also try to adapt the alternative wrapper script flamelw.sh to use docker community and your distro security settings (I hope you won't just disable SElinux). The alterantive wrapper script was reported by a few content developers as working as-is on Windows and MacOS. Unfortunately I don't have good Mac and Windows machines to keep the wrapper script updated myself. Sometimes I test on a crappy Windows Home netbook.

### Questions

Please ask any questions to Fernando Lozano <flozano@redhat.com> or on the #curriculum-core room on Google Chat. I'll do my best to help you but cannot commit to any SLA ;-)

I usually lag a day or two behind package updates from Nikki.

## Caveats

If you environment sets a local DNS server, such as for Vagrant, Minikube, CDK, and Code Ready Containers, your resolv.conf may be invalid for a container, for example because it sets 127.0.0.1 as the DNS server.

If this is your scenario, you need to customize the flamel.sh wrapper script to add a proper DNS configuration using the **--dns** and **--dns-search** options from podman. To do so, edit the wrapper script and uncomment the DNSOPTS variable. Also change its content to match the DNS settings of your VPN endpoint:


```
# DNS options for Red Hat VPN using RDU2
#DNSOPTS="--dns-search redhat.com --dns 10.11.5.19 --dns 10.5.30.160"
```

Similar issues with DNS may surface when building the container using the podman build command. Because it does not accept dns options, you have to change yout /etc/resolv.conf file before building the container. Fortunately, that most users **don't** need to build containers; they just need a wrapper script and the prebuilt images at quay.io.

## Pending

CI/CD updates of the container image with new flamel, branding, or slides packages, ~~maybe using Quay.io build support~~. Building the container requires access to the Red Hat VPN to access the GLS package repos. Maybe the Open Platform fits the bill? https://mojo.redhat.com/docs/DOC-1099943

## Older updates

### 2020-02-11 UPDATE

Prebuilt image tag 0.3 (and 0.3-5) updated with flamel 2.1.19-1, redhat-training-xsl 1.1.18-1, and 1.2.3-1.

The wrapper script now recognizes the --tag and --purge options. The first one allows overriding the image tag and can be conbined with other options and arguments. The second one removes local container images, so the next run can download an updated container image.

These updates were not applyed yet to the flamelw.sh wrapper script.

Building an IG is known to work for quite some time. Just remember to run 'flamel clean' before running 'flamel ig'. IG still uses the old branding but this is not a failure of the container.

### 2019-08-15 UPDATE

Prebuilt image tag 0.3 replaces env vars that provide the versions for flamel and other packages with ARG. Now the same Dockerfile can built from latest packages on the curricum Yum repo, or with specific versions (for regression tests, for example).

The wrapper script now recognizes the --check option, that instead of running flamel, runs a script that reports package versions inside the container. If you are connected to the VPN, it also compares the versions of the local packages with the latest on the curriculum repo. This way you can verify that your books are using the latest brading package.

Razique reports that the flamelw.sh script works unchanged on MacOS with Hyperkit. Just copy it to yours ~/bin/flamel and he happy!

### 2019-07-30 UPDATE

Prebuilt image tag 0.2 is updated with redhat-training-xsl-v1.1.15, flamel-2.1.18, and reveal-js-slide-generator 1.2.0.

Rootless mode is now the default. Change the rootless variable inside the script to revert to the old behavior using sudo.

New env vars BRANDING, FLAMEL, and SLIDES to make it easy to check which releases are included into the pre-built container image using skopeo or podman inspect, without the need to create a container. Also new env var CURRICULUM for the release of the curriculum-release package.

New flamelw.sh script that uses Docker tools, tested on a Windows 10 Home machine.

### 2019-07-10 UPDATE

The wrapper script was tested rootless in RHEL 8 CSB and works fine.

### 2019-07-09 UPDATE

Now the container and wrapper script take command-line arguments to flamel. It is not hardcoded to 'flamel sg' anymore. You can do 'flamel.sh sg', 'flamel.sh ig' etc. Image tag '0.1' contains this update, 'latest' remains hardcoded to 'flamel sg'.

End of README.