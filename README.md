# Introduction
While watching an episode of Ghost in the Shell, I noticed how they used the 
idea of printing sequences of PDF-417 barcode images to store digital data on 
paper. It was used in an attempt to smuggle data out of the country, which was 
probably not very realistic, but the idea to use barcodes to store data on paper
is interesting. PDF-417, though looking cool and futuristic, is neither a very 
good way to encode data, for its low data capacity per code.

Sometimes storing relatively small amounts of digital data in a safe place can 
be very important. Think of PGP/GPG encryption keys, SSH private keys, or any 
other data that is crucial to get access to important secured information. Of 
course there is a use case for digital online backups, or putting a USB stick 
with a digital copy in your fault, but in some (paranoid) situations paper still
remains a more reliable and controllable medium.

One option is to encode data in Base64 and print it directly to paper. This 
method has a disadvantage in that you would either need a lot of tedious typing
to recover or some very good OCR program to automate the recovery. Either way, 
this method does not perform well in terms of error detection and error 
correction. QR-codes on the other hand, perform good in terms of error detection
and error correction and can be decoded successfully with a range of tools. To 
decode data that was encodes as a series of images on paper, all one needs to do
is put each page on a flatbed scanner and cut the scanned images into individual
qr-code pictures. These pictures can then be fed to a script decoding them and 
concatenating their data into a file.

File2qr will take a file, both ASCII and binary, and produce a series of PNG 
images with the encoded contents of the file. These images can then be printed 
to paper for storage. Placing around 9 – 12 images in a square table in a 
document should work fine. Qr2file will take a series of PNG images, decode 
them and place their combined contents into a file.


# Dependencies
Because file2qr and qr2file are python scripts, python is a dependency.
In addition to that, there are these dependencies:

## file2qr:
qrencode

## qr2file:
python-imaging
python-zbar

## examples/export_gpg_keys.sh:
pgpdump


# Caveats
These tools are not well suited for large file. For files with ASCII data, 1024
bytes will be encoded in each image. Because qr-codes do not support binary 
data, binary data is encoded as base64 string inside each image, resulting in
only 768 bytes of actual content per image. So, a 1Mb file with ASCII data will
require 1024 images to encode, and a binary file even 1366. Unless you love
large collections of qr-code images, it should be clear that these tools should
only be used to encode small amounts of data.

If the qr-code images need to be decoded by any other tool than qr2file, the
procedure for ASCII data is straight forward. Just decode each qr-code and then
concatenate the result into a file. For binary data, the procedure is a little
different. Here you need, only on the first image, to strip the 'B64:' prefix
from data. Then the data of each image needs to be Base64 decoded. After that,
the data can be concatenated into a file.


# Installation
To install the scripts on your machine, simply:
```bash
make install
```

and to uninstall:
```bash
make uninstall
```

# Usage
To encode a file:
```bash
file2qr <input_file> <output_file_base>
```

This will encode <input_file> to a series of PNG images, with names that start 
with <output_file_base>. If the optional <output_file_base> is omitted, the
name of the imput file is being used as a base for the output files.

To decode a series of qr-code images:
```bash
ls -1 <input_file_base>.*.png | qr2file <output_file>
```
This will take a collection of PNG images and decode them back into a file 
called <output_file>

# Examples
The examples directory contains a couple of scripts with practical examples.

## export_gpg_keys.sh:
This script will export GPG keys (public and private) of the current user and 
any of his/her contacts.

## export_ssh_keys.sh:
This script will export all SSH keys (public and private) on a system.
This script will as for a root password if run as a regular user.
