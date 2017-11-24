# cihm-ingestwip
Docker image building for WIP tools, as well as SIP creation and AIP ingest


This code impliments our current custom processes that staff use to take files (most often digitised images), create descriptive metadata (most often CSV or DB/Text files with Dublin Core or our cutom IssueInfo format), optionally generate OCR and then generate SIPs which eithor update or create AIPs within our OAIS repository.

The longer-term plan is to replace most of this code with processes and automation around [Archivematica](https://www.archivematica.org).  Currently our web access platform is closely tied to our OAIS preservation platform, which we will be upgrading to use Archivematica DIPs as input to a platform that no longer reaches deep into the OAIS platform to offer images online.


