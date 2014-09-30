#!/bin/sh
# take a top-level directory from old OUCS,
# get the HTML, and clean it up
scriptdir=`dirname $0`
DOWNLOAD=true
APPHOME=`(cd $scriptdir; pwd)`
export PATH=$APPHOME:$PATH

while test $# -gt 0; do
  case $1 in
    --nodownload) DOWNLOAD=false;;
     *) if test "$1" = "${1#--}" ; then 
	   break
	else
	   echo "WARNING: Unrecognized option '$1' ignored"
	fi ;;
  esac
  shift
done

cd /tmp
mkdir -p www.oucs.ox.ac.uk
mkdir -p www.oucs.ox.ac.uk.ok
rm -rf www.oucs.ox.ac.uk/$1
if [ $DOWNLOAD = 'true' ]
then
    echo 1. Fetch http://www.oucs.ox.ac.uk/$1
    wget  -nv -l inf -np -nc -r -x -E --trust-server-names http://www.oucs.ox.ac.uk/$1/
    cd www.oucs.ox.ac.uk
    tar cf - $1 | (cd ../www.oucs.ox.ac.uk.ok; tar xf - )
else
    cd www.oucs.ox.ac.uk    
    rsync -a ../www.oucs.ox.ac.uk.ok/$1/  $1/
fi

echo 2. processing $1
echo 3. remove duplicates
find $1 -name "*style=text.html" -exec rm -v {} \;
find $1 -name "*.1.html" -exec rm -v {} \;
find $1 -name "*splitLevel=*" -exec rm -v {} \;
find $1 -name "*style=screen.html" -exec rm -v {} \;
find $1 -name "*ID=*" -exec rm -v {} \;
echo 4. Look for occasions where directory.html == directory/index.xml.html
for i in `find $1 -type d`
do 
    test -f $i.html && test -f $i/index.xml.html && diff -q $i.html $i/index.xml.html && echo $i.html is SPURIOUS && rm $i.html
    test -f $i.html && test -f $i/index.html && diff -q $i.html $i/index.html && echo $i.html is SPURIOUS && rm $i.html
    [ -f $i.html ] && [ ! -f $i/index.html ] && echo moving $i.html to $i/index.html && mv $i.html $i/index.html
done

mkdir -p images
mkdir -p resources
:>IMAGES.JOB
echo 5. Looking at HTML and XML files
for i in `find $1 -name "*.xml*" -o -name "*.html*"`
do
    D=`dirname $i`
    case `basename $i` in
    index.html) 
	echo "5.1 ==== $i (HTML index file) ===="
	perl -p -i -e 's+<html[^<]*>+<html xmlns="http://www.w3.org/1999/xhtml">+' $i
	perl -p -i -e 's+<HTML[^<]*>+<HTML xmlns="http://www.w3.org/1999/xhtml">+' $i
	(java -jar $APPHOME/htmlcleaner-2.7.jar src=$i outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-drupal1.xsl basename=`basename $i .html` fname=$D/index.html dirname=$D ) >& JOB$$
	;;
    *.shtml.html) 
	echo "5.1 ==== $i (SHTML file) ===="
	perl -p -i -e 's+<html[^<]*>+<html xmlns="http://www.w3.org/1999/xhtml">+' $i
	perl -p -i -e 's+<HTML[^<]*>+<HTML xmlns="http://www.w3.org/1999/xhtml">+' $i
	N=`echo $i | sed 's/.shtml//'`
	(java -jar $APPHOME/htmlcleaner-2.7.jar src=$i incharset=iso-8859-1 outcharset=utf-8 outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-drupal1.xsl basename=`basename $i .shtml.html` fname=$N dirname=$D && rm $i) >& JOB$$
	;;
    *.xml.html)
	echo "5.1 ==== $i (XML file translated to HTML) ===="
	(java -jar $APPHOME/htmlcleaner-2.7.jar src=$i outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-drupal1.xsl fname=$i basename=`basename $i .html` dirname=$D && rm $i) >& JOB$$
	;;
    *)
	echo "5.1 ==== $i (other) ===="
	perl -p -i -e 's+<html[^<]*>+<html xmlns="http://www.w3.org/1999/xhtml">+' $i
	perl -p -i -e 's+<HTML[^<]*>+<HTML xmlns="http://www.w3.org/1999/xhtml">+' $i
	(java -jar $APPHOME/htmlcleaner-2.7.jar src=$i outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-drupal1.xsl fname=$i basename=`basename $i .html` dirname=$D ) >& JOB$$
	;;
    esac
    egrep "^cp|^curl" JOB$$ >> IMAGES.JOB
    egrep -v "^cp|^curl" JOB$$
    rm JOB$$
done

for i in `find $1 -name "*.html*"`
do
    echo "5.2. ==== $i ===="
    if ( echo $i | grep -q -- "-\.html" )
    then  
	echo 5.2.1 kill $i && rm $i
    else 
	(saxon -s:$i -xsl:$APPHOME/mangle-drupal2.xsl fname=$i dname=$1 > $i.new) 
	mv $i.new $i
	perl -p -i -e 's/<(div|p|ul|ol|table)/\n<\1/g' $i
    fi
done
echo 6. Do image job
sh -x IMAGES.JOB
egrep "^cp" IMAGES.JOB | awk '{print "rm -v " $2}' | sh -x

echo 7. remove any empty  directories
for i in `find $1 -type d`
do
   if [ ! "$(ls -A $i)" ]; then       
    rmdir $i && echo removed $i
  fi
done



