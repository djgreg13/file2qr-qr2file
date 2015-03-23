#!/bin/bash
################################################################################
 # Example script to export all GPG keys of a user and his/her contacts.
 # Results will be stored in a subdirectory called 'gpg'.
 #
 # LICENSE: GNU GENERAL PUBLIC LICENSE Version 3
 #
 # @author      Elwin Andriol
 # @copyright   Copyright (c) 2015 Heuveltop (http://www.heuveltop.nl)
 # @license     http://www.gnu.org/licenses/gpl.html GPLv3
 # @version     $Id:$
 # @link        https://github.com/eandriol/file2qr-qr2file
 ###############################################################################

[ -d gpg ] && rm -rf gpg
mkdir gpg

for section in public secret; do
  for key in `gpg --list-${section}-keys | grep "^${section:0:3}" | cut -c 13-20`; do
  	[ ! -d gpg/${key} ] && mkdir gpg/${key}
  	
    echo "exporting ${section} key ${key}:"
    if [ "${section}" == "public" ]; then
      gpg --armor --export ${key} > gpg/${key}/${key}.${section:0:3}.asc
    else
      gpg --armor --export-${section}-keys ${key} > gpg/${key}/${key}.${section:0:3}.asc
    fi

    name=gpg/${key}/${key}.${section:0:3}
    
    echo "ID:" > ${name}.nfo
    pgpdump ${name}.asc | grep '^\s*User ID' | sed 's|^\s*User ID - |  |' >> ${name}.nfo

    echo " - encoding image files"
    file2qr ${name}.asc ${name}

    echo " - decoding image files"
    ls -1 ${name}.*.png | qr2file ${name}.test

    echo -n " - comparing results: "

    if [ -z "$(diff ${name}.asc ${name}.test)" ]; then
      echo "successful"
      rm ${name}.test
      rm ${name}.asc
    else
      echo "failed"
      [ -n "$(ls ${name}.*.png 2>/dev/null)" ] && rm ${name}.*.png
      mv ${name}.test ${name}.failed
    fi

    echo
  done
done
