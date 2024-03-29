ARG FEDORA_VERSION=38

FROM quay.io/fedora/fedora-coreos:stable as kernel-query
RUN rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}' > /kernel-version.txt

FROM registry.fedoraproject.org/fedora:${FEDORA_VERSION} as builder
### setup builder
ARG FEDORA_VERSION
COPY --from=kernel-query /kernel-version.txt /kernel-version.txt
WORKDIR /etc/yum.repos.d
RUN curl -L -O https://src.fedoraproject.org/rpms/fedora-repos/raw/f${FEDORA_VERSION}/f/fedora-updates-archive.repo && \
    sed -i 's/enabled=AUTO_VALUE/enabled=true/' fedora-updates-archive.repo
RUN dnf install -y jq dkms gcc make autoconf automake libtool rpm-build libtirpc-devel libblkid-devel \
    libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel \
    kernel-$(cat /kernel-version.txt) kernel-modules-$(cat /kernel-version.txt) kernel-devel-$(cat /kernel-version.txt) \
    python3 python3-devel python3-setuptools python3-cffi libffi-devel git ncompress libcurl-devel

RUN mkdir /tmp/rpms
### setup builder

### zfs ###
WORKDIR /
RUN curl -s -L -H 'X-GitHub-Api-Version: 2022-11-28' https://api.github.com/repos/openzfs/zfs/releases | jq -r '.[0].assets[].browser_download_url | select(endswith(".tar.gz"))' > /tmp/zfs_url.txt
RUN echo "ZFS URL: $(cat /tmp/zfs_url.txt)"
RUN curl -L -o zfs.tar.gz "$(cat /tmp/zfs_url.txt)" \
    && mkdir /zfs \
    && tar xzf zfs.tar.gz --strip-components=1 --directory=/zfs
WORKDIR /zfs
RUN ./configure --with-linux=/usr/src/kernels/$(cat /kernel-version.txt)/ --with-linux-obj=/usr/src/kernels/$(cat /kernel-version.txt)/ \
    && make -j$(nproc) rpm-utils rpm-kmod

RUN rm -f zfs-test*.rpm *debuginfo*.rpm *debugsource*.rpm *devel*.rpm zfs-dracut*.rpm *.src.rpm python*.rpm \
    && mv *.x86_64.rpm /tmp/rpms
### zfs ###

FROM quay.io/fedora/fedora-coreos:stable

COPY --from=builder /tmp/rpms/*.rpm /tmp/rpms/
RUN rpm-ostree install /tmp/rpms/*.rpm \
    && rm -rf /var/lib/pcp

RUN ostree container commit
