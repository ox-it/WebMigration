#!/bin/sh
# take a top-level directory from old BSP
# clean it up
scriptdir=`dirname $0`
DOWNLOAD=true
APPHOME=`(cd $scriptdir; pwd)`
export PATH=$APPHOME:$PATH

echo Starting from $APPHOME
cd /tmp
mkdir -p www.it.ox.ac.uk
mkdir -p www.it.ox.ac.uk.ok
rm -rf www.it.ox.ac.uk/$1
echo 1. Fetch http://www.it.ox.ac.uk/$1
wget  -nv -l inf -np -nc -r -x -E --trust-server-names http://www.it.ox.ac.uk/$1/
cd www.it.ox.ac.uk
mkdir -p images
mkdir -p resources
:>IMAGES.JOB
echo 1. Looking at HTML files
for i in `find $1 -name "*.html*"`
do
    D=`dirname $i | sed 's/\/web\//\/webcms\//'`
    M=`echo $i | sed 's/\/web\//\/webcms\//'`
    perl -p -i -e 's/ \& / \&amp; /g' $i
    perl -p -i -e 's/data-behaviour=/ data-behaviour=/' $i
    perl -p -i -e "s/alt='''//" $i
    perl -p -i -e "s/alt=''//" $i
    case `basename $i` in
    index.html) 
    (java -jar $APPHOME/htmlcleaner-2.7.jar src=$i incharset=utf-8 outcharset=utf-8 outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-wwwit1.xsl basename=`basename $M .html` fname=$M dirname=$D ) >& JOB$$
	;;
    *)
	echo "1.2 ==== $i (other) ===="
	perl -p -i -e 's+<html[^<]*>+<html xmlns="http://www.w3.org/1999/xhtml">+' $i
	perl -p -i -e 's+<HTML[^<]*>+<HTML xmlns="http://www.w3.org/1999/xhtml">+' $i
	(java -jar $APPHOME/htmlcleaner-2.7.jar src=$i outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-wwwit1.xsl fname=$Mi basename=`basename $M .html` dirname=$D ) >& JOB$$
	;;
    esac

    egrep "^cp|^curl" JOB$$ >> IMAGES.JOB
    egrep -v "^cp|^curl" JOB$$
    rm JOB$$
done

for i in `find $1 -name "*.html*"`
do
    echo "1.2. ==== $i ===="
    if ( echo $i | grep -q -- "-\.html" )
    then  
	echo 1.2.1 kill $i && rm $i
    else 
	(saxon -s:$i -xsl:$APPHOME/mangle-wwwit2.xsl fname=$i dname=$1 > $i.new) 
	mv $i.new $i
	perl -p -i -e 's/<(div|p|ul|ol|table)/\n<\1/g' $i
    fi
done
echo 3. Do image job
sh -x IMAGES.JOB
egrep "^cp" IMAGES.JOB | awk '{print "rm -v " $2}' | sh -x

echo 4. remove any empty  directories
for i in `find $1 -type d`
do
   if [ ! "$(ls -A $i)" ]; then       
    rmdir $i && echo removed $i
  fi
done

