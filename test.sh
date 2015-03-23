#!/bin/bash
################################################################################
 # Script to test and time the encoding and decoding of both a 1M binary and a 
 # 1M ASCII text file.
 #
 # LICENSE: GNU GENERAL PUBLIC LICENSE Version 3
 #
 # @author      Elwin Andriol
 # @copyright   Copyright (c) 2015 Heuveltop (http://www.heuveltop.nl)
 # @license     http://www.gnu.org/licenses/gpl.html GPLv3
 # @version     $Id:$
 # @link        https://github.com/eandriol/file2qr-qr2file
 ###############################################################################

[ -d tmp ] && rm -rf tmp
mkdir tmp

echo "creating binary test file"
dd bs=1024 count=1024 2>/dev/null </dev/urandom >tmp/test.in
ls -hal tmp/test.in
echo

echo -n "encoding test file..."
time (python file2qr.py tmp/test.in tmp/test)
echo

echo -n "decoding test file..."
time(ls -1 tmp/test.*.png | python qr2file.py tmp/test.out)
echo

echo "images used to encode test file: $(ls -1 tmp/test.*.png | wc -l)"
echo

echo "file diff and checksums"
diff -uN tmp/test.in tmp/test.out
md5sum tmp/test.{in,out}
echo

rm -rf tmp
mkdir tmp

echo
echo "creating ascii test file"
dd bs=768 count=1024  2>/dev/null </dev/urandom | base64 -w 0 >tmp/test.in
ls -hal tmp/test.in
echo

echo -n "encoding test file..."
time (python file2qr.py tmp/test.in tmp/test)
echo

echo -n "decoding test file..."
time(ls -1 tmp/test.*.png | python qr2file.py tmp/test.out)
echo

echo "images used to encode test file: $(ls -1 tmp/test.*.png | wc -l)"
echo

echo "file diff and checksums"
diff -uN tmp/test.in tmp/test.out
md5sum tmp/test.{in,out}
echo

rm -rf tmp
