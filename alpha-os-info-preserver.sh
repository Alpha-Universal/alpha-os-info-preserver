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
if [[ ! -x /usr/bin/inotifywait ]] ; then
	apt update && apt install -y inotify-tools
fi

# creates an Alpha log directory, if not already present
if [[ ! -d /var/log/alpha ]] ; then
	mkdir /var/log/alpha
fi

# define pertinent files
aos_osr_file="/etc/alpha-scripts/system/templates/alpha-os-info-preserver/os-release"
usr_osr_file="/usr/lib/os-release"

# create needed checksums for all os-release files 
aos_sha="$(sha256sum ${aos_osr_file} | awk '{print $1 }')"
		
# compares both checksums and searches for a failure result
# true is used because sha256sum exits with failure on checksum mismatches,
# which bombs this script
sha_comp="$(echo "${aos_sha}  ${usr_osr_file}" | sha256sum -c - || true)"
		
# define the comparison result
sha_result=0
if [[ -n "$(echo "${sha_comp}" | grep FAILED)" ]] ; then
	sha_result=1
fi

# sets inotify to monitor both os-release files in the background
while inotifywait --daemon --outfile /var/log/alpha/alpha-os-info-preserver.log \
	--event modify,create,attrib --timefmt "%F - %R:%S" --format "%w %e @ %T" /usr/lib/os-release ; do
		# exits if no differences were found
		# exit is called here because inotifywait will otherwise keep 
		# spawning processes
		if [[ "${sha_result}" == 0 ]] ; then
			echo "No os-release differences found. Exiting"
			exit 0
		else
		# restores Alpha OS file after modifications were made to system defaults
			echo "The os-release files differ. Installing replacement in /usr/lib"
			cp "${aos_osr_file}" "${usr_osr_file}" 
			exit 0
		fi
	done
	
exit 0
