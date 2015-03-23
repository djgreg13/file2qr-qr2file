#!/bin/bash
################################################################################
 # Example script to export a system's ssh keys as qr-coded images.
 # Results will be stored in a subdirectory called 'ssh'.
 #
 # LICENSE: GNU GENERAL PUBLIC LICENSE Version 3
 #
 # @author      Elwin Andriol
 # @copyright   Copyright (c) 2015 Heuveltop (http://www.heuveltop.nl)
 # @license     http://www.gnu.org/licenses/gpl.html GPLv3
 # @version     $Id:$
 # @link        https://github.com/eandriol/file2qr-qr2file
 ###############################################################################

if [ `id -u` -ne 0 ]; then
    su -c "$0 ${USER}"; s=$?; [ ${s} -ne 0 ] && exit 1; [ ${s} -eq 0 ] && exit 0
fi

if [ -n "$1" ]; then
	user=$1
else
	user=${USER}
fi

[ -d ssh ] && rm -rf ssh
mkdir ssh

for pub_file in `find /etc/ssh -name *.pub` `find /root/.ssh -name *.pub` `find /home/*/.ssh -name *.pub`; do
  sec_file="$(echo ${pub_file} | sed 's|\.pub$||')"

  for section in secret public; do
    [ "${section}" == "public" ] && file=${pub_file}
    [ "${section}" == "secret" ] && file=${sec_file}
    base="ssh${file}"

    echo "export ${section} key ${file}"
    [ ! -d $(dirname ${base}) ] && mkdir -p $(dirname ${base})
	echo "fingerprint: $(ssh-keygen -lf ${file} | awk '{print $2}')" > ${base}.nfo
	
    echo " - encoding image files"
    file2qr ${file} ${base}

    echo " - decoding image files"
    ls -1 ${base}.*.png | qr2file ${base}.test

    echo -n " - comparing encoding/decoding: "

    if [ -z "$(diff ${file} ${base}.test)" ]; then
      echo "successful"
      rm ${base}.test
    else
      echo "failed"
      [ -n "$(ls ${base}.*.png 2>/dev/null)" ] && rm ${base}.*.png
      mv ${base}.test ${base}.failed
    fi

    echo

  done
done

chown -R ${user}:${user} ssh
