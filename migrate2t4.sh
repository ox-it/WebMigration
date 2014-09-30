#!/bin/sh
# take a top-level directory from old OUCS,
# get the HTML, and clean it up
scriptdir=`dirname $0`
APPHOME=`(cd $scriptdir; pwd)`
cd /tmp
rm -rf www.oucs.ox.ac.uk/$1
echo Fetch http://www.oucs.ox.ac.uk/$1
wget  -nv -m -np --html-extension http://www.oucs.ox.ac.uk/$1/
echo Start processing www.oucs.ox.ac.uk/$1
find www.oucs.ox.ac.uk/$1 -name "*style=text.html" -exec rm {} \;
find www.oucs.ox.ac.uk/$1 -name "*style=screen.html" -exec rm {} \;
cd  www.oucs.ox.ac.uk
for i in `find $1 -name "*.xml*" -o -name "*.html*"`
do
    echo "1. ==== $i ===="
    if [ `basename $i` = index.html ]
    then
	D=`dirname $i`
	(xmllint --noent --dropdtd $i | saxon -s:- -xsl:$APPHOME/mangle.xsl style=t4 basename=`basename $i .html` fname=$D/index.xml dirname=$D ) >& JOB$$
    else
	(xmllint --noent --dropdtd $i | saxon -s:- -xsl:$APPHOME/mangle.xsl style=t4 fname=$i basename=`basename $i .html` dirname=`dirname $i` && rm $i) >& JOB$$
    fi
    egrep "^mv|^curl" JOB$$ | sh -x
    egrep -v "^mv|^curl" JOB$$
    rm JOB$$
done

for i in `find $1 -name "*.html*"`
do
    echo "2. ==== $i ===="
    if ( echo $i | grep -q -- "-\.html" )
    then  
	echo kill $i
	rm $i
    else 
	(saxon -s:$i -xsl:$APPHOME/mangle-pass2.xsl style=t4 fname=$i dname=$1 | xmllint --format --encode utf8 - > $i.new) >> JOB$$ 2>&1
    fi
done
echo Commands to do:
cat JOB$$
echo Now do them:
sh JOB$$
rm JOB$$
echo Done
# remove any empty  directories
for i in `find $1 -type d`
do
   if [ ! "$(ls -A $i)" ]; then       
    rmdir $i
  fi
done

