FROM registry.fedoraproject.org/fedora:30

MAINTAINER Fernando Lozano <flozano@redhat.com>

# Make sure we get English error messages to share with the team
ENV LANG=en_US.utf-8 \
  BOOK=/tmp/coursebook

COPY http://wiki.gls.redhat.com/curriculum-repos/fedora/30/x86_64/curriculum-release-fedora-22-1.fc30.noarch.rpm /tmp

RUN dnf -y install /tmp/*rpm \
  && dnf --nodocs -y install flamel redhat-training-xsl git \
  && dnf clean all \
  && mkdir -p ${BOOK}

VOLUME ${BOOK}

WORKDIR ${BOOK}/guides
ENTRYPOINT [ "flamel" ]