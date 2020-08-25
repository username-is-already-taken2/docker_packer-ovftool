FROM ubuntu:16.04

ENV PACKER_VERSION=1.6.1
ENV PACKER_SHA256SUM=8dcf97610e8c3907c23e25201dce20b498e1939e89878dec01de6975733c7729

ENV OVFTOOL_VERSION 4.3.0-13981069
ENV OVFTOOL_INSTALLER VMware-ovftool-${OVFTOOL_VERSION}-lin.x86_64.bundle
# checksum verified at https://my.vmware.com/group/vmware/get-download?downloadGroup=OVFTOOL430U3
ENV OVFTOOL_SHA1SUM=522e0142427e8e61b706898c8fa1e1199411f0bd

RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
RUN echo "${PACKER_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" | sha256sum -c - && unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && rm -f packer_${PACKER_VERSION}_linux_amd64.zip


ADD https://www.dropbox.com/s/3sztls2h25f1aiz/${OVFTOOL_INSTALLER}?dl=1 ./
RUN echo "${OVFTOOL_SHA1SUM} ${OVFTOOL_INSTALLER}" | sha1sum -c - && sh ${OVFTOOL_INSTALLER} -p /usr/local --console --eulas-agreed --required && rm ${OVFTOOL_INSTALLER}

ENTRYPOINT ["/bin/packer"]
