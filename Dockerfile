FROM ubuntu:focal

ENV PACKER_VERSION=1.6.1
ENV PACKER_SHA256SUM=8dcf97610e8c3907c23e25201dce20b498e1939e89878dec01de6975733c7729

ENV OVFTOOL_VERSION=4.4.0-16360108
ENV OVFTOOL_INSTALLER=VMware-ovftool-${OVFTOOL_VERSION}-lin.x86_64.bundle
# checksum verified at https://my.vmware.com/group/vmware/downloads/get-download?downloadGroup=OVFTOOL440P01
ENV OVFTOOL_SHA256SUM=553f7dcf8b26c881fe7e6eedb17865601b32ae20b2ee04d3f74744d5f593448ca

ENV MONDOO_VERSION=0.60.0
RUN curl https://releases.mondoo.io/mondoo/${VERSION}/mondoo_${VERSION}_linux_amd64.tar.gz | tar -xvzC /usr/local/bin

RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
RUN echo "${PACKER_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" | sha256sum -c - && unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && rm -f packer_${PACKER_VERSION}_linux_amd64.zip

ADD https://www.dropbox.com/s/1jm3dkstxlan8pn/${OVFTOOL_INSTALLER}?dl=1 ./
RUN echo "${OVFTOOL_SHA256SUM} ${OVFTOOL_INSTALLER}" | sha256sum -c - && sh ${OVFTOOL_INSTALLER} -p /usr/local --console --eulas-agreed --required && rm ${OVFTOOL_INSTALLER}

ENTRYPOINT ["/bin/packer"]
