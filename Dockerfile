FROM registry.fedoraproject.org/fedora:30

MAINTAINER Fernando Lozano <flozano@redhat.com>

# Adding "-subrelease" to packages, such as SLIDES="-1.2.0-1", breaks the build.
# Having the dash as part of each version string allows installing whatever is latest by default, or forcing the build to use a fixed release

ARG CURRICULUM="-22-1"
ARG BRANDING
ARG BRANDINGIG
ARG FLAMEL
ARG SLIDES

# Make sure we get English error messages to share with the team.

ENV LANG="en_US.utf-8" \
  BOOK="/tmp/coursebook" 

COPY http://wiki.gls.redhat.com/curriculum-repos/fedora/30/x86_64/curriculum-release-fedora${CURRICULUM}.fc30.noarch.rpm /tmp

RUN dnf -y install /tmp/*rpm \
  && dnf --nodocs --setopt=install_weak_deps=False -y install \
    publican-gls-redhat-new${BRANDINGIG} redhat-training-xsl${BRANDING} reveal-js-slide-generator${SLIDES} \
    interstate-fonts overpass-fonts flamel${FLAMEL} git-core \
  && dnf clean all \
  && mkdir -p ${BOOK}

COPY check-gls-packages.sh /tmp

VOLUME ${BOOK}

WORKDIR ${BOOK}/guides

ENTRYPOINT [ "flamel" ]

