Containerized famel for Red Hat Training Books

This Dockerfile builds a Fedora-based container for flamel, with the GLS branding and customizations, in the hope you can use it to build books on any Linux distro and, who knows, even MacOS. (I don't think there are any Windows users in out team).

It is a very basic container, the magic is on the flamel.sh wrapper script, that uses the container over a local folder.

A container image is available at quay.io/flozanorht/flamel as a public image, I should probably move it into a private repo that only the GLS team can access.

Copy the script to a folder in your path, such as ~/bin, and run the script from your guides folder, just like you would do with a local installation of flamel.

Please ask any questions to Fernando Lozano <flozano@redhat.com> or on the #curriculum-core room on Google Chat.

