#!/usr/bin/env python
################################################################################
 # File2qr will encode a file to a series of qr-code PNG images.
 #
 # LICENSE: GNU GENERAL PUBLIC LICENSE Version 3
 #
 # @author      Elwin Andriol
 # @copyright   Copyright (c) 2015 Heuveltop (http://www.heuveltop.nl)
 # @license     http://www.gnu.org/licenses/gpl.html GPLv3
 # @version     $Id:$
 # @link        https://github.com/eandriol/file2qr-qr2file
 ###############################################################################

from base64     import b64encode
from math       import ceil, log10
from os         import path, stat
from re         import search
from subprocess import PIPE, Popen
from sys        import argv, exit

BASE64ENCODE = False
BUFFERSIZE = 1024

QR_LEVEL  = 'H' 
QR_MARGIN = 4
QR_PIXELS = 3

def generate( data, filename ):
    if BASE64ENCODE:
        if search( '\.0+\.png$', filename ) != None:
            data = 'B64:' + b64encode( data )
        else:
            data = b64encode( data )
    
    output = Popen(
        [
            'qrencode',
            '-o', filename,
            '-l', QR_LEVEL,
            '-m', '%d' % QR_MARGIN,
            '-s', '%d' % QR_PIXELS,
            '--', data
        ],
        stdout = PIPE,
        stderr = PIPE
      ).communicate()
    
    if output[ 1 ]:
        print 'qrencode -o %s -l %s -m %d -s %d' % ( filename, QR_LEVEL, QR_MARGIN, QR_PIXELS )
        print output[ 1 ]

def is_binary( filename ):
    output = Popen( 
        [ 
           'file',
           '-b',
           '--mime',
           filename
        ],
        stdout = PIPE
    ).communicate()
    
    return search( 'charset=us-ascii', output[ 0 ] ) == None

def show_usage():
    print "usage: file2qr <input_filename> <optional_output_basename>"

if __name__ == "__main__":
    if len( argv ) < 2:
        show_usage()
        exit( 1 )
    
    basename = filename = argv[ 1 ]
    
    if not path.exists( filename ):
        show_usage()
        exit( 1 )
    
    if len( argv ) == 3:
        basename = argv[ 2 ]
        
    if is_binary( filename ):
        BASE64ENCODE = True
        BUFFERSIZE = BUFFERSIZE * 3 / 4
    
    if stat( filename ).st_size < BUFFERSIZE:
        precision = 1
    else:
        precision = ceil( log10( stat( filename ).st_size / BUFFERSIZE ) )
    
    with open( filename, 'rb' ) as f:
        index = 0
        buffer = ''
        byte = f.read( 1 )
        
        while len( byte ):
            buffer += byte
            
            if len( buffer ) == BUFFERSIZE:
                format = '%s.%%0%dd.png' % ( basename, precision )
                resultname = format % index
                generate( buffer, resultname );
                index += 1
                buffer = ''
            
            byte = f.read( 1 )
        
        if len( buffer ):
            format = '%s.%%0%dd.png' % ( basename, precision )
            resultname = format % index
            generate( buffer, resultname );
