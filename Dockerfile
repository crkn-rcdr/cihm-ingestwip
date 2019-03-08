FROM ubuntu:trusty-20190122

# Same layer as cihm-metadatabus -- benefit to keeping in sync
RUN groupadd -g 1117 tdr && useradd -u 1117 -g tdr -m tdr && \
    mkdir -p /etc/canadiana /var/log/tdr /var/lock/tdr && ln -s /home/tdr /etc/canadiana/tdr && chown tdr.tdr /var/log/tdr /var/lock/tdr && \
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq cpanminus build-essential libxml-libxml-perl libxml-libxslt-perl libio-aio-perl rsync && apt-get clean

RUN groupadd -g 1115 cihm && useradd -u 1015 -g cihm -m cihm && \ 
    ln -s /home/tdr /etc/canadiana/wip && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq libxml2-utils openjdk-6-jdk subversion poppler-utils imagemagick perlmagick && apt-get clean

# Upgrades to Imagemagik now have a policy file which needs to be adjusted.
# https://stackoverflow.com/questions/42928765/convertnot-authorized-aaaa-error-constitute-c-readimage-453
RUN sed -ie 's/rights="none" pattern="PDF" \/>/rights="read|write" pattern="PDF" \/>\n<policy domain="coder" rights="read|write" pattern="LABEL" \/>/' /etc/ImageMagick/policy.xml

# JHOVE needs to be able to validate abbyy finereader generated files, and loc.gov now has firewall.
RUN mkdir -p /opt/xml && svn co https://github.com/crkn-rcdr/Digital-Preservation.git/trunk/xml /opt/xml/current && \
    xmlcatalog --noout --add uri http://www.loc.gov/standards/xlink/xlink.xsd file:///opt/xml/current/unpublished/xsd/xlink.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.loc.gov/alto/v3/alto-3-0.xsd file:///opt/xml/current/unpublished/xsd/alto-3-0.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.loc.gov/alto/v3/alto-3-1.xsd file:///opt/xml/current/unpublished/xsd/alto-3-1.xsd /etc/xml/catalog && \
    xmlcatalog --noout --add uri http://www.w3.org/2001/03/xml.xsd file:///opt/xml/current/unpublished/xsd/xml.xsd /etc/xml/catalog

WORKDIR /home/tdr
COPY cpanfile* *.conf *.xml /home/tdr/

# Build recent JHOVE. Reports are currently added to SIP. Failed validation doesn't stop processing
RUN curl -OL http://software.openpreservation.org/rel/jhove/jhove-1.18.jar && \
    java -jar jhove-1.18.jar jhove-auto-install.xml && mv jhove.conf /opt/jhove/conf

# Our application is perl code, which we added to a local PINTO server as modules.  Other dependencies are from CPAN.
ENV PERL_CPANM_OPT "--mirror http://pinto.c7a.ca/stacks/c7a-perl-devel/ --mirror http://www.cpan.org/"
RUN cpanm -n --installdeps . && rm -rf /root/.cpanm || (cat /root/.cpanm/work/*/build.log && exit 1)

#RUN curl -OL http://pinto.c7a.ca/deploy/CIHM-WIP-0.15.tar.gz && cpanm CIHM-WIP-0.15.tar.gz

# Sometimes 'tdr', sometimes 'cihm'.  Picked one for the default
USER tdr
