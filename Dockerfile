FROM buildpack-deps:buster

RUN groupadd -g 1117 tdr && useradd -u 1117 -g tdr -m tdr && \
    mkdir -p /etc/canadiana /var/log/tdr /var/lock/tdr && ln -s /home/tdr /etc/canadiana/tdr && chown tdr.tdr /var/log/tdr /var/lock/tdr && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq cpanminus build-essential libxml-libxml-perl libxml-libxslt-perl libio-aio-perl rsync cron postfix sudo && apt-get clean

ENV TINI_VERSION 0.18.0
RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends wget; \
    rm -rf /var/lib/apt/lists/*; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    \
# install tini
    wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-$dpkgArch"; \
    wget -O /usr/local/bin/tini.asc "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-$dpkgArch.asc"; \
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7; \
    gpg --batch --verify /usr/local/bin/tini.asc /usr/local/bin/tini; \
    rm -r "$GNUPGHOME" /usr/local/bin/tini.asc; \
    chmod +x /usr/local/bin/tini; \
    tini --version; \
    \
    apt-get purge -y --auto-remove wget ; apt-get clean

RUN groupadd -g 1115 cihm && useradd -u 1015 -g cihm -m cihm && \ 
    ln -s /home/tdr /etc/canadiana/wip && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq xml-core libxml2-utils subversion poppler-utils imagemagick-6.q16 libimage-magick-perl ghostscript && apt-get clean

# Upgrades to Imagemagik now have a policy file which needs to be adjusted.
# https://stackoverflow.com/questions/42928765/convertnot-authorized-aaaa-error-constitute-c-readimage-453
RUN echo "\n<policy domain=\"coder\" rights=\"read|write\" pattern=\"PDF\" />\n<policy domain=\"coder\" rights=\"read|write\" pattern=\"LABEL\" \/>/" >>/etc/ImageMagick-6/policy.xml

# Cache some xsd's for validation
RUN mkdir -p /opt/xml && svn co https://github.com/crkn-rcdr/Digital-Preservation.git/trunk/xml /opt/xml/current && \
    xmlcatalog --noout --add uri http://www.loc.gov/standards/xlink/xlink.xsd file:///opt/xml/current/unpublished/xsd/xlink.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.loc.gov/alto/v3/alto-3-0.xsd file:///opt/xml/current/unpublished/xsd/alto-3-0.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.loc.gov/alto/v3/alto-3-1.xsd file:///opt/xml/current/unpublished/xsd/alto-3-1.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.w3.org/2001/03/xml.xsd file:///opt/xml/current/unpublished/xsd/xml.xsd /etc/xml/catalog

WORKDIR /home/tdr
COPY cpanfile* *.conf *.xml /home/tdr/
COPY aliases /etc/aliases

RUN cpanm -n --installdeps . && rm -rf /root/.cpanm || (cat /root/.cpanm/work/*/build.log && exit 1)

COPY CIHM-Normalise CIHM-Normalise
COPY CIHM-Meta CIHM-Meta
COPY CIHM-METS-App CIHM-METS-App
COPY CIHM-METS-parse CIHM-METS-parse
COPY CIHM-TDR CIHM-TDR
COPY CIHM-Swift CIHM-Swift
COPY CIHM-WIP CIHM-WIP


COPY docker-entrypoint.sh /
ENTRYPOINT ["tini", "--", "/docker-entrypoint.sh"]
USER root
