# alpha-os-info-preserver
When upgraded, Switchboard (the Settings GUI for the Pantheon DE) overwrites 
/usr/lib/os-release to identify the system as eOS, and to utilize links to 
https://elementary.io for support, project info, and etc.

The files in this package set all links (except the link for suggesting
translations) to the relevant areas of https://alpha.store, and preserves
Alpha OS info across Switchboard upgrades.

The individual files are automatically placed and called once the deb 
is installed to your system.  They are posted alongside the deb to facilitate 
auditing and collaboration.  
