<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" 
		xpath-default-namespace="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xs tei"
		version="2.0">
  <xsl:output method="text"/>

<xsl:template name="main">
  <xsl:variable name="docs" select="collection('/tmp/www.oucs.ox.ac.uk?select=*.html;recurse=yes;on-error=warning')"/> 
    <xsl:for-each-group  select="$docs//*[@class]" group-by="concat(name(),':',@class)">
      <xsl:value-of select="(current-grouping-key(), count(current-group()))" separator=","/><xsl:text>
</xsl:text>
    </xsl:for-each-group>
  </xsl:template>
</xsl:stylesheet>
