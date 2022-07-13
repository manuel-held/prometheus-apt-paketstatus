#!/bin/bash
#
# Description: Expose metrics from apt updates.
#
# Author: Ben Kochie <superq@gmail.com>
# Author: Manuel Held <manuel@held.is>

upgrades="$(/usr/bin/apt-get --just-print dist-upgrade \
  | /usr/bin/awk -F'[()]' \
      '/^Inst/ { sub("^[^ ]+ ", "", $2); gsub(" ","",$2);
                 sub("\\[", " ", $2); sub("\\]", "", $2); print $2 }' \
  | /usr/bin/sort \
  | /usr/bin/uniq -c \
  | awk '{ gsub(/\\\\/, "\\\\", $2); gsub(/"/, "\\\"", $2);
           gsub(/\[/, "", $3); gsub(/\]/, "", $3);
           print "apt_upgrades_pending{origin=\"" $2 "\",arch=\"" $NF "\"} " $1}'
)"

autoremove="$(/usr/bin/apt-get --just-print autoremove \
  | /usr/bin/awk '/^Remv/{a++}END{printf "apt_autoremove_pending %d", a}'
)"
security_upgrades="$(apt list --upgradable 2>&1 | grep -c "\-security")"
echo '# HELP apt_upgrades_pending Apt package pending updates by origin.'
echo '# TYPE apt_upgrades_pending gauge'
if [[ -n "${upgrades}" ]] ; then
  echo "${upgrades}"
else
  echo 'apt_upgrades_pending{origin="",arch=""} 0'
fi

echo '# HELP apt_autoremove_pending Apt package pending autoremove.'
echo '# TYPE apt_autoremove_pending gauge'
echo "${autoremove}"

echo '# HELP node_reboot_required Node reboot is required for software updates.'
echo '# TYPE node_reboot_required gauge'
if [[ -f '/run/reboot-required' ]] ; then
  echo 'node_reboot_required 1'
else
  echo 'node_reboot_required 0'
fi

echo '# HELP apt_securityupgrades_pending Apt package pending updates by origin.'
echo '# TYPE apt_securityupgrades_pending gauge'
echo "apt_securityupgrades_pending ${security_upgrades}"