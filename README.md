Containerized famel for Red Hat Training Books

2019-07-09 UPDATE: Now the container and wrapper script take command-line arguments to flamel. It is not hardcoded to 'flamel sg' anymore. You can do 'flamel.sh sg', 'flamel.sh ig' etc. Image tag '0.1' contains this update, 'latest' remains hardcoded to 'flamel sg'.

This Dockerfile builds a Fedora-based container for flamel, with the GLS branding and customizations, in the hope you can use it to build student guide and instructor guide PDF books on any Linux distro and, who knows, even MacOS. (I don't think there are any Windows users in our team).

It is a very basic container, the magic is on the flamel.sh wrapper script, that mounts the current working dir as a volume in the container.

A container image is available at quay.io/flozanorht/flamel as a public image, I should probably move it into a private repo that only the GLS team can access.

Copy the script to a folder in your path, such as ~/bin, and run the script from your guides folder, just like you would do with a local installation of flamel.

Yes, the flamel.sh script is very hacky, I need to find a better way to manage SELinux labels and the ./tmp folder. And learn how to do rootless podman, which I wasn't able to do yet in my RHEL 7.6 CSB. :-(

Please ask any questions to Fernando Lozano <flozano@redhat.com> or on the #curriculum-core room on Google Chat.

