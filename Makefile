all: convert zip html css links

convert:
	(for i in `grep migrate AllDirs.txt | sed 's/^.//' | sed 's/\".*//'`; do sh ./migrate2drupal.sh $$i; done) >& LOG.migrate

links:
	saxon -it:main getlinks.xsl > LOG.links

css:
	saxon -it:main getcss.xsl > LOG.css

html:
	saxon -it:main gethtml.xsl > LOG.html

zip:
	(cd /tmp/www.oucs.ox.ac.uk; zip -r ~/drupalimport-`date "+%Y-%m-%d"` `find . -name "*.html"` resources images)

count:
	for i in `cat AllDirs.txt | sed 's/^.//' | sed 's/\".*//'`; do (cd ../publish; find $i -name "*.xml*" -o -name "*.html" | wc -l); done > s.txt
