FROM ubuntu:16.04

ENV PACKER_VERSION=1.4.3
ENV PACKER_SHA256SUM=c89367c7ccb50ca3fa10129bbbe89273fba0fa6a75b44e07692a32f92b1cbf55

ENV OVFTOOL_VERSION 4.3.0-12320924
ENV OVFTOOL_INSTALLER VMware-ovftool-${OVFTOOL_VERSION}-lin.x86_64.bundle
# checksum verified at https://my.vmware.com/group/vmware/get-download?downloadGroup=OVFTOOL430U2
ENV OVFTOOL_SHA1SUM=54ae517e741d5a6c00350b5b5eb4bd72ed124a78

RUN apt-get update && \
    apt-get -y install unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
RUN echo "${PACKER_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" | sha256sum -c - && unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && rm -f packer_${PACKER_VERSION}_linux_amd64.zip

ADD https://www.dropbox.com/s/dx9klzj4ec0d938/${OVFTOOL_INSTALLER}?dl=1 ./
RUN echo "${OVFTOOL_SHA1SUM} ${OVFTOOL_INSTALLER}" | sha1sum -c - && sh ${OVFTOOL_INSTALLER} -p /usr/local --console --eulas-agreed --required && rm ${OVFTOOL_INSTALLER}

ENTRYPOINT ["/bin/packer"]
