#!/bin/bash
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

set -e

export PERL5LIB=/home/tdr/CIHM-Meta/lib:/home/tdr/CIHM-METS-App/lib:/home/tdr/CIHM-METS-parse/lib:/home/tdr/CIHM-TDR/lib:/home/tdr/CIHM-WIP/lib:/home/tdr/CIHM-Normalise/lib
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/tdr/CIHM-Meta/bin:/home/tdr/CIHM-METS-App/bin:/home/tdr/CIHM-METS-parse/bin:/home/tdr/CIHM-TDR/bin:/home/tdr/CIHM-WIP/bin:/home/tdr/CIHM-Normalise/bin


cronandmail ()
{
	# Postfix setup
	# needs to be in running container so local randomly generated hostname can be in main.cf
	debconf-set-selections /home/tdr/postfix-debconf.conf
	rm /etc/postfix/*.cf
        dpkg-reconfigure -f noninteractive postfix
	service postfix start

	# Cron in foreground
	/usr/sbin/cron -f

	# For debugging purposes it is possible to exec into a running container and start rsyslogd to see output of cron.
}


echo "export PATH=$PATH" >> /root/.profile
echo "export PERL5LIB=$PERL5LIB" >> /root/.profile

echo "export PATH=$PATH" >> /home/tdr/.profile
echo "export PERL5LIB=$PERL5LIB" >> /home/tdr/.profile
chown tdr.tdr /home/tdr/.profile

echo "export PATH=$PATH" >> /home/cihm/.profile
echo "export PERL5LIB=$PERL5LIB" >> /home/cihm/.profile
chown cihm.cihm /home/cihm/.profile

echo "MAILTO=sysadmin@c7a.ca" > /etc/cron.d/ingestwip
echo "PATH=$PATH" >> /etc/cron.d/ingestwip
echo "PERL5LIB=$PERL5LIB" >> /etc/cron.d/ingestwip

if [ "$1" = 'packaging' ]; then
	cat <<-IWCRONP >>/etc/cron.d/ingestwip
# Move files between packaging stages
* * * * * cihm /bin/bash -c "wip-move"
# Look for work, including generating SIPs
0/10 * * * * cihm /bin/bash -c "wip-tdrexport ; wip-unitize; wip-imageconv ; wip walk --quiet ; wip-metsproc ; mallet"
# Weekday morning report
35 6 * * 1-5 cihm /bin/bash -c "wip walk --quiet --report=rmcormond@crkn.ca,bstover@crkn.ca,pbrisson@crkn.ca,mgott@crkn.ca"
# Clean packaging trashcan
35 0 * * * cihm /bin/bash -c "find /opt/wip/Trashcan -mindepth 1 -delete"
IWCRONP
        cronandmail
elif [ "$1" = 'ingest' ]; then
        cat <<-IWCRONI >>/etc/cron.d/ingestwip
# Ingest (SIP or metadata updates into AIPs)
5/10 * * * * tdr /bin/bash -c "tdringest --maxprocs=2"
# Clean out the directory used for temporary files during ingest
36 4 * * * tdr /bin/bash -c "mkdir -p /home/tdr/tempIngest/sipvalidate ; find /home/tdr/tempIngest/sipvalidate -mindepth 1 -maxdepth 1 -mmin +360 -exec rm -rf {} \;"
IWCRONI
        cronandmail
elif [ "$1" = 'tdr' ]; then
    shift
    # Otherwise run what was asked as the 'tdr' user
    exec sudo -u tdr -i "$@"
elif [ "$1" = 'cihm' ]; then
    shift
    # Otherwise run what was asked as the 'cihm' user
    exec sudo -u cihm -i "$@"
else
    echo "First parameter must be known"
    exit 1
fi
