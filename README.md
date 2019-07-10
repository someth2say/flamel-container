Containerized famel for Red Hat Training Books

2019-07-09 UPDATE: Now the container and wrapper script take command-line arguments to flamel. It is not hardcoded to 'flamel sg' anymore. You can do 'flamel.sh sg', 'flamel.sh ig' etc. Image tag '0.1' contains this update, 'latest' remains hardcoded to 'flamel sg'.

2019-07-10 UPDATE: the wrapper script was tested rootless in RHEL 8 CSB and works fine.

This Dockerfile builds a Fedora-based container for flamel, with the GLS branding and customizations, in the hope you can use it to build student guide and instructor guide PDF books and also HTML5 slides on any Linux distro and, who knows, even MacOS. (I don't think there are any Windows users in the GLS team).

It is a very basic container image, based on Fedora 30. The magic is on the flamel.sh wrapper script, that mounts the current working dir as a volume in the container, with podman options that allow the host folder to be shared by multiple containers, and sets SELinux labels on the host folder so it can be shared between the host and a container.

A pre-built container image is available at quay.io/flozanorht/flamel as a public image. I should probably move it into a private repo that only the GLS team can access.

Copy the script to a folder in your path, such as ~/bin, and run the script from your guides folder, just like you would do with an RPM-based installation of flamel. Optionally rename the script from 'flamel.sh' to just 'flamel' so it works as a true drop-in replacement, including being used by pre-commit.

The script asks for sudo, for the benefit of RHEL7 users. If you wish to run rootless, just change a variable in the beginning of the script. Generating slides also works. Rootless should work with either RHEL8 or Fedora 30.

Please ask any questions to Fernando Lozano <flozano@redhat.com> or on the #curriculum-core room on Google Chat.

PENDING:

Formal verification that the container image really includes all bits to generate release books.

Tests using instructor guide.

