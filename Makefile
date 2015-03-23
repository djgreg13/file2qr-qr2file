################################################################################
 # Makefile for installing and uninstalling file2qr and qr2file
 #
 # LICENSE: GNU GENERAL PUBLIC LICENSE Version 3
 #
 # @author      Elwin Andriol
 # @copyright   Copyright (c) 2015 Heuveltop (http://www.heuveltop.nl)
 # @license     http://www.gnu.org/licenses/gpl.html GPLv3
 # @version     $Id:$
 # @link        https://github.com/eandriol/file2qr-qr2file
 ###############################################################################

.PHONY: install
.PHONY: uninstall

BIN=/usr/bin

################################################################################
 # install
 ###############################################################################
install:
	cp file2qr.py $(BIN)/file2qr
	cp qr2file.py $(BIN)/qr2file
	chmod 0777 $(BIN)/file2qr
	chmod 0777 $(BIN)/qr2file

################################################################################
 # uninstall
 ###############################################################################
uninstall:
	if [ -f $(BIN)/file2qr ]; then rm $(BIN)/file2qr; fi
	if [ -f $(BIN)/qr2file ]; then rm $(BIN)/qr2file; fi
