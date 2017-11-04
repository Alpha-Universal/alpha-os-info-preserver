#!/bin/bash -

#   Name    :   alpha-os-info-preserver.sh
#   Author  :   Richard Buchanan II for Alpha Universal, LLC
#   Brief   :   A script to watch the os-release file in 
#               /usr/lib for changes, and restore Alpha OS
#               info when modifications are found.
#               
#				Doing this makes all links and info in Pantheon's
#				Switchboard > About point to Alpha.  The default
#				after upgrades is to revert info and links
#				back to eOS.
#

set -o errexit      # exits if non-true exit status is returned
set -o nounset      # exits if unset vars are present

PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin

# installs needed programs
if [[ ! -x /usr/bin/inotify-hookable ]] ; then
	apt update && apt install -y inotify-hookable
fi

# creates an Alpha log directory, if not already present
if [[ ! -d /var/log/alpha ]] ; then
	mkdir /var/log/alpha
fi

# define pertinent files
aos_osr_file="/etc/alpha-scripts/system/templates/alpha-os-info-preserver/os-release"
usr_osr_file="/usr/lib/os-release"
aos_log_file="/var/log/alpha/alpha-os-info-preserver.log"

# sets inotify-hookable to monitor /usr/lib/os-release in the background
# the & is required at the end, or i-h will time out on systemd
while true ; do
    inotify-hookable -f /usr/lib/os-release -c cp "${aos_osr_file} ${usr_osr_file}"
	echo "$(date +%F) at $(date +%H:%M:%S) - os-release was modified" >> "${aos_log_file}"
done &
