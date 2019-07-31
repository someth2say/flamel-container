FROM registry.fedoraproject.org/fedora:30

MAINTAINER Fernando Lozano <flozano@redhat.com>

# Make sure we get English error messages to share with the team.
# Adding "-subrelease" to packages, such as SLIDES="1.2.0-1", breaks the build.

ENV LANG="en_US.utf-8" \
  BOOK="/tmp/coursebook" \
  CURRICULUM="22-1" \
  BRANDING="1.1.15" \
  FLAMEL="2.1.18" \
  SLIDES="1.2.0"

COPY http://wiki.gls.redhat.com/curriculum-repos/fedora/30/x86_64/curriculum-release-fedora-${CURRICULUM}.fc30.noarch.rpm /tmp

RUN dnf -y install /tmp/*rpm \
  && dnf --nodocs -y install \
    publican-gls-redhat-new redhat-training-xsl-${BRANDING} reveal-js-slide-generator-${SLIDES} \
    interstate-fonts overpass-fonts flamel-${FLAMEL} git \
  && dnf clean all \
  && mkdir -p ${BOOK}

VOLUME ${BOOK}

WORKDIR ${BOOK}/guides
ENTRYPOINT [ "flamel" ]
