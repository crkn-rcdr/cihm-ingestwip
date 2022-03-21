# Packaging filesystem

Management of files used by the packaging system is done using tools such as FileZilla or Nautilus which support the sftp protocol.

After logging in the /packaging/ directory has a series of subdirectories

* Stages which the files for a package can be in:
  * Assembly/
  * Processing/
  * Rejected/
  * Trashcan/ - This last one is special, as files are peridically cleared from the Trashcan.

* Temp/ - Temporary files not used by any automation. Staff copy files here and then "move" in a single command into other directories to avoid tools trying to handle partially uploaded directories.
* Unitization/ - Scanned periodically by `wip-unitize` tool
* aipdir/ - Temporary directory where AIPs are stored while they are being manipulated, prior to being copied to Swift repository.

* Readme.html - Simple html that will redirect a web browser to this page.
