<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" 
		xpath-default-namespace="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xs tei"
		version="2.0">
  <xsl:output omit-xml-declaration="yes" indent="no" encoding="UTF-8"/>
  <xsl:param name="fname"/>
  <xsl:param name="dname"/>

  <xsl:variable name="top" select="/"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|processing-instruction()|comment()|text()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|processing-instruction()|comment()">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="parent::h1|parent::h2|parent::h3|parent::h4">
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:when>
      <xsl:when test="parent::pre">
	<xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
	<!-- Retain one leading space if node isn't first, has non-space content, and has leading space.-->
        <xsl:if test="position()!=1 and normalize-space(substring(., 1, 1)) = '' and normalize-space()!=''">
            <xsl:text> </xsl:text>
        </xsl:if>        
        <xsl:value-of select="normalize-space(.)"/>
        <!-- Retain one trailing space if node isn't last, isn't first, and has trailing space 
                                       or node isn't last, is first, has trailing space, and has any non-space content  
                                       or node is an only child, and has content but it's all space-->
        <xsl:if test="position()!=last() and position()!=1 and normalize-space(substring(., string-length())) = ''
                   or position()!=last() and position() =1 and normalize-space(substring(., string-length())) = '' and normalize-space()!=''
                   or last()=1 and string-length()!=0 and normalize-space()='' ">
            <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  </xsl:stylesheet>
  
