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
    <xsl:for-each select="$docs//a/@href">
      <xsl:value-of select="('link',base-uri(/),.)"/><xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="$docs//*/@id">
      <xsl:value-of select="('id',base-uri(/),.)"/><xsl:text>
</xsl:text>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
