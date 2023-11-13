ARG FEDORA_VERSION=38

FROM registry.fedoraproject.org/fedora-toolbox:${FEDORA_VERSION}

RUN yum install -y ripgrep micro