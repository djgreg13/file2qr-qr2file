#!/usr/bin/env python
################################################################################
 # File2qr will dencode a series of qr-code PNG images back to a file.
 #
 # LICENSE: GNU GENERAL PUBLIC LICENSE Version 3
 #
 # @author      Elwin Andriol
 # @copyright   Copyright (c) 2015 Heuveltop (http://www.heuveltop.nl)
 # @license     http://www.gnu.org/licenses/gpl.html GPLv3
 # @version     $Id:$
 # @link        https://github.com/eandriol/file2qr-qr2file
 ###############################################################################

from base64  import b64decode
from Image   import open as openImage
from os      import path, remove
from re      import search
from sys     import argv, exit, stdin
from zbar    import Config, Image, ImageScanner, Symbol

BASE64DECODE = False

def extract( filename ):
    scanner = ImageScanner()
    scanner.set_config( 0, Config.ENABLE, 0 )
    scanner.set_config( Symbol.QRCODE, Config.ENABLE, 1 )
    img = openImage( filename ).convert( 'L' )
    width, height = img.size
    raw = img.tostring()
    image = Image( width, height, 'Y800', raw )
    result = scanner.scan( image )

    if result == 0: 
        return False
    else:
        result = False
        
        for symbol in image:
            if symbol.type == Symbol.QRCODE:
                result = symbol.data
                break
        
        del( image )
        return result

def show_usage():
    print "usage: ls -1 <name>.*.png | qr2file <output_filename>"

if __name__ == "__main__":
    if len( argv ) != 2:
        show_usage()
        exit( 1 )
    
    resultname = argv[ 1 ]
    first = True
    
    if path.exists( resultname ):
        remove( resultname )
    
    for filename in map( str.strip, stdin.readlines() ):
        data = extract( filename )
        
        if data:
            #print "decoded %s" % filename
            
            if first:
                if search( '\.0+\.png$', filename ) != None:
                    if data[ 0 : len( 'B64:' ) ] == 'B64:':
                        BASE64DECODE = True
                        data = data[ len( 'B64:' ) : ]
                
                first = False
            
            if BASE64DECODE:
                try:
                    data = b64decode( data )
                except:
                    print "failed to decode %s" % filename
                    print "len: %d" % len( data )
                    print data
                    continue
            
            if path.exists( resultname ):
                with open( resultname, 'ab' ) as f:
                    f.write( data )

            else:
                with open( resultname, 'wb' ) as f:
                    f.write( data )
            
        else:
            print "failed to extract %s" % filename
