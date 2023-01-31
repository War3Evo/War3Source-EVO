#!/bin/bash
cd "$(dirname "$0")"

fullpath=${PWD};

test -e compiled || mkdir compiled

newfilename=${@##*/}

#echo $@
#echo $newfilename

# ./spcomp
#-t<num>  TAB indent size (in character positions, default=8)
#-v<num>  verbosity level; 0=quiet, 1=normal, 2=verbose (default=1)
#-;[+/-]  require a semicolon to end each statement (default=-)
#         -O<num>  optimization level (default=-O2)
#             0    no optimization
#             2    full optimizations

if [[ $# -ne 0 ]]
then
	for i in "$newfilename";
	do
		fullpathsourcefile="`echo $fullpath/$i`";
		smxfile="`echo $i | sed -e 's/\.sp$/\.smx/'`";
		outputfile="`echo $fullpath/compiled/$smxfile`"
		echo -n "Single File Compiling $i...";
		./spcomp_1.9.0.6261 -t4 -v2 $fullpathsourcefile -o$outputfile
	done
else
	for sourcefile in *.sp
	do
		fullpathsourcefile="`echo $fullpath/$sourcefile`";
		smxfile="`echo $sourcefile | sed -e 's/\.sp$/\.smx/'`";
		echo -n "All Files Compiling $sourcefile...";
		./spcomp_1.9.0.6261 -t4 -v2 $fullpathsourcefile -ocompiled/$smxfile;
	done
fi
