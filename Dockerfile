FROM ubuntu:focal

ENV PACKER_VERSION=1.6.1
ENV PACKER_SHA256SUM=8dcf97610e8c3907c23e25201dce20b498e1939e89878dec01de6975733c7729

ENV OVFTOOL_VERSION=4.4.0-16360108
ENV OVFTOOL_INSTALLER=VMware-ovftool-${OVFTOOL_VERSION}-lin.x86_64.bundle
# checksum verified at https://my.vmware.com/group/vmware/downloads/get-download?downloadGroup=OVFTOOL440P01
ENV OVFTOOL_SHA256SUM=53f7dcf8b26c881fe7e6eedb17865601b32ae20b2ee04d3f74744d5f593448ca
ENV OVFTOOL_URL=https://www.dropbox.com/s/1jm3dkstxlan8pn/${OVFTOOL_INSTALLER}?dl=1

ARG MONDOO_VERSION=0.62.0 \
  MONDOO_INSTALLER=mondoo_${MONDOO_VERSION}_linux_amd64.tar.gz \
  MONDOO_SHA256SUM=effe11b2e517db2caab2b35e288d865adb611be9692c978c1d5745df2938ffab

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq && \
    apt-get -y install unzip wget curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Using the following method creates a smaller image, need to retro fit this into each package.
#RUN mkdir /tmp/app && \
#    wget -O /tmp/app/${OVFTOOL_INSTALLER} ${OVFTOOL_URL} && \
#    echo "${OVFTOOL_SHA256SUM} /tmp/app/${OVFTOOL_INSTALLER}" | sha256sum -c - && \
#    sh /tmp/app/${OVFTOOL_INSTALLER} -p /usr/local --console --eulas-agreed --required && \
#    rm -rf /tmp/app/

# Added Mondoo Packer Plugin
RUN mkdir -p ~/.packer.d/plugins && \
  cd ~/.packer.d/plugins && \
  curl -sSL https://github.com/mondoolabs/packer-provisioner-mondoo/releases/latest/download/packer-provisioner-mondoo_linux_amd64.tar.gz | tar -xz > packer-provisioner-mondoo && \
  chmod +x packer-provisioner-mondoo

ADD ${OVFTOOL_URL} ./
# latest version of OVFTOOL expects this locale to exist otherwise it errors
RUN apt-get update -qq && \
  apt-get install locales -y -qq && \
  locale-gen en_US.UTF-8 && \
  echo "${OVFTOOL_SHA256SUM} ${OVFTOOL_INSTALLER}" | sha256sum -c - && \
  sh ${OVFTOOL_INSTALLER} -p /usr/local --console --eulas-agreed --required && \
  rm -f ${OVFTOOL_INSTALLER} && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ADD https://releases.mondoo.io/mondoo/${MONDOO_VERSION}/${MONDOO_INSTALLER} ./
RUN echo "${MONDOO_SHA256SUM} ${MONDOO_INSTALLER}" | sha256sum -c - && tar -xvzC /usr/local/bin --file=${MONDOO_INSTALLER} && rm -f ${MONDOO_INSTALLER}

ADD https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip ./
RUN echo "${PACKER_SHA256SUM} packer_${PACKER_VERSION}_linux_amd64.zip" | sha256sum -c - && unzip packer_${PACKER_VERSION}_linux_amd64.zip -d /bin && rm -f packer_${PACKER_VERSION}_linux_amd64.zip

ENTRYPOINT ["/bin/packer"]
