FROM perl:5.36.0

RUN groupadd -g 1117 tdr && useradd -u 1117 -g tdr -m tdr && \
    mkdir -p /etc/canadiana /var/log/tdr /var/lock/tdr && ln -s /home/tdr /etc/canadiana/tdr && chown tdr.tdr /var/log/tdr /var/lock/tdr && \
    ln -sf /usr/share/zoneinfo/America/Montreal /etc/localtime && \
    ln -s /usr/include/x86_64-linux-gnu/ImageMagick-6/ /usr/local/include/ && \
    ln -s /home/tdr /etc/canadiana/wip && \
    groupadd -g 1115 cihm && useradd -u 1015 -g cihm -m cihm && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq rsync sudo cpanminus build-essential \
    xml-core subversion poppler-utils  imagemagick-6-common libmagickcore-6.q16-6 ghostscript \
    libxml-libxml-perl libxml-libxslt-perl \
    libxml2-dev libxml2-utils xml-core libaio-dev libxslt1-dev libssl-dev && \
    apt-get clean

# Upgrades to Imagemagik now have a policy file which needs to be adjusted.
# https://stackoverflow.com/questions/42928765/convertnot-authorized-aaaa-error-constitute-c-readimage-453
# We've also had memory issues.
# https://stackoverflow.com/questions/31407010/cache-resources-exhausted-imagemagick
RUN echo "\n<policy domain=\" coder\" rights=\"read|write\" pattern=\"PDF\" />\n<policy domain=\"coder\" rights=\"read|write\" pattern=\"LABEL\" \/>/" >>/etc/ImageMagick-6/policy.xml && \
    sed -i -E 's/name="memory" value=".+"/name="memory" value="8GiB"/g' /etc/ImageMagick-6/policy.xml && \
    sed -i -E 's/name="map" value=".+"/name="map" value="8GiB"/g' /etc/ImageMagick-6/policy.xml && \
    sed -i -E 's/name="area" value=".+"/name="area" value="8GiB"/g' /etc/ImageMagick-6/policy.xml && \
    sed -i -E 's/name="disk" value=".+"/name="disk" value="8GiB"/g' /etc/ImageMagick-6/policy.xml

# Cache some xsd's for validation
RUN mkdir -p /opt/xml && svn co https://github.com/crkn-rcdr/Digital-Preservation.git/trunk/xml /opt/xml/current && \
    xmlcatalog --noout --add uri http://www.loc.gov/standards/xlink/xlink.xsd file:///opt/xml/current/unpublished/xsd/xlink.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.loc.gov/alto/v3/alto-3-0.xsd file:///opt/xml/current/unpublished/xsd/alto-3-0.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.loc.gov/alto/v3/alto-3-1.xsd file:///opt/xml/current/unpublished/xsd/alto-3-1.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.w3.org/2001/03/xml.xsd file:///opt/xml/current/unpublished/xsd/xml.xsd /etc/xml/catalog

WORKDIR /home/tdr
COPY Archive-BagIt-0.054.tar.gz cpanfile* *.conf *.xml /home/tdr/
COPY aliases /etc/aliases

RUN cpanm -n --installdeps . && rm -rf /root/.cpanm || (cat /root/.cpanm/work/*/build.log && exit 1)
RUN cpanm -n --reinstall /home/tdr/Archive-BagIt-0.054.tar.gz && rm -rf /root/.cpanm || (cat /root/.cpanm/work/*/build.log && exit 1)

COPY CIHM-METS-App CIHM-METS-App
COPY CIHM-TDR CIHM-TDR
COPY CIHM-Swift CIHM-Swift
COPY CIHM-WIP CIHM-WIP


ENV PERL5LIB /home/tdr/CIHM-METS-App/lib:/home/tdr/CIHM-TDR/lib:/home/tdr/CIHM-Swift/lib:/home/tdr/CIHM-WIP/lib:/usr/share/perl5
ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/tdr/CIHM-METS-App/bin:/home/tdr/CIHM-TDR/bin:/home/tdr/CIHM-Swift/bin:/home/tdr/CIHM-WIP/bin
SHELL ["/bin/bash", "-c"]
USER tdr
