#!/bin/sh
# take a top-level directory from old BSP
# clean it up
scriptdir=`dirname $0`
DOWNLOAD=true
APPHOME=`(cd $scriptdir; pwd)`
export PATH=$APPHOME:$PATH

echo Starting from $APPHOME
cd /tmp
mkdir -p bsp
rm -rf bsp/$1
(cd $APPHOME/bsp; tar cf - $1) | (cd bsp; tar xf -)
cd bsp
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
    (java -jar $APPHOME/htmlcleaner-2.7.jar src=$i incharset=utf-8 outcharset=utf-8 outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-bsp1.xsl basename=`basename $M .html` fname=$M dirname=$D ) >& JOB$$
	;;
    *)
	echo "1.2 ==== $i (other) ===="
	perl -p -i -e 's+<html[^<]*>+<html xmlns="http://www.w3.org/1999/xhtml">+' $i
	perl -p -i -e 's+<HTML[^<]*>+<HTML xmlns="http://www.w3.org/1999/xhtml">+' $i
	(java -jar $APPHOME/htmlcleaner-2.7.jar src=$i outputtype=simple omitXmlDeclaration=true omitDoctypeDeclaration=true | saxon -s:- -xsl:$APPHOME/mangle-bsp1.xsl fname=$Mi basename=`basename $M .html` dirname=$D ) >& JOB$$
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
	(saxon -s:$i -xsl:$APPHOME/mangle-bsp2.xsl fname=$i dname=$1 > $i.new) 
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

cp $APPHOME/Guidance_on_the_use_of_oxonly.pdf /tmp/bsp/resources/services_webcms_support_Guidance_on_the_use_of_oxonly.pdf
cp $APPHOME/Site_Manager_7.1_-_Contributor_v0.2.docx /tmp/bsp/resources/services_webcms_support_Site_Manager_7.1_-_Contributor_v0.2.docx
cp $APPHOME/Site_Manager_7.1_-_Moderator_v0.2.docx /tmp/bsp/resources/services_webcms_support_Site_Manager_7.1_-_Moderator_v0.2.docx
cp $APPHOME/Site_Manager_workarounds.docx /tmp/bsp/resources/services_webcms_support_Site_Manager_workarounds.docx
cp $APPHOME/TemplateGuide-v10.docx /tmp/bsp/resources/services_webcms_support_TemplateGuide-v10.docx
cp $APPHOME/Web_content_style_guide.pdf /tmp/bsp/resources/services_webcms_support_Web_content_style_guide.pdf
