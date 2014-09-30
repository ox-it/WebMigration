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

  <xsl:template match="div[@class='page_header']">
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

  <xsl:template match="h1|h2|h3|h4">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|processing-instruction()|comment()|text()" />
    </xsl:copy>
  </xsl:template>

<xsl:template match="h2[parent::div/@class='body_firstcontent']"/>

<xsl:template match="li[@class='breadcrumb-first']"/>

<xsl:template match="a">
  <xsl:copy>
  <xsl:choose>
    <xsl:when test="@class='breadcrumb'">
      <xsl:variable name="L" select="tokenize(@href,'/')"/>
      <xsl:variable name="L2" select="tokenize($fname,'/')"/>
      <xsl:variable name="Diff" select="count($L2)-count($L)"/>
      
	<xsl:apply-templates select="@*[not(name(.)='pagetitle')]"/>
	
	<xsl:variable name="Title">
	  <xsl:choose>
	    <xsl:when test="matches(@href,'\.html$')">
	      <xsl:value-of
		  select="@pagetitle"/>
	    </xsl:when>
	    <xsl:when test="$Diff=-1 and doc-available(resolve-uri('index.html',base-uri($top)))">
	      <xsl:value-of
		  select="tei:cutdown(doc(resolve-uri('index.html',base-uri($top)))/html/head/title)"/>
	    </xsl:when>
	    <xsl:when test="$Diff=0 and doc-available(resolve-uri('../index.html',base-uri($top)))">
	      <xsl:value-of
		  select="tei:cutdown(doc(resolve-uri('../index.html',base-uri($top)))/html/head/title)"/>
	    </xsl:when>
	    <xsl:when test="$Diff=1 and doc-available(resolve-uri('../../index.html',base-uri($top)))">
	      <xsl:value-of
		  select="tei:cutdown(doc(resolve-uri('../../index.html',base-uri($top)))/html/head/title)"/>
	    </xsl:when>
	    <xsl:when test="$Diff=2 and doc-available(resolve-uri('../../../index.html',base-uri($top)))">
	      <xsl:value-of
		  select="tei:cutdown(doc(resolve-uri('../../../index.html',base-uri($top)))/html/head/title)"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:message>echo "FAIL WITH <xsl:value-of select="(@href,$Diff)"/>"</xsl:message>
	      <xsl:text>(unknown)</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<!--<xsl:message>BREAD <xsl:value-of select="(text(),@pagetitle,@href,$Diff,$Title)" separator=" ... "/></xsl:message>-->
	<xsl:value-of select="$Title"/>

    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="href">
	<xsl:variable name="basename"
		      select="tokenize($fname,'/')[last()]"/>
	<xsl:variable name="pat">
	  <xsl:text>^</xsl:text>
	  <xsl:value-of select="$basename"/>
	  <xsl:text>#.+$</xsl:text>
	</xsl:variable>
	<xsl:choose>
	  <xsl:when test="matches(@href,$pat)">
	    <xsl:value-of select="concat('#',substring-after(@href,'#'))"/>
	    	    <xsl:message>echo HASH REF <xsl:value-of select="@href"/></xsl:message>
	  </xsl:when>
	  <xsl:when test="starts-with(@href,'../../../../')">
	    <xsl:value-of select="tei:dotdot(4,@href)"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@href,'../../../')">
	    <xsl:value-of select="tei:dotdot(3,@href)"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@href,'../../')">
	    <xsl:value-of select="tei:dotdot(2,@href)"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@href,'../')">
	    <xsl:value-of select="tei:dotdot(1,@href)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="replace(@href,'-\.html','.html')"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="@*[not(name()='href')]"/>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
  </xsl:copy>
  </xsl:template>
  
  <xsl:function name="tei:cutdown" as="xs:string">
    <xsl:param name="in"/>
    <xsl:value-of select="replace(normalize-space($in),' - .*','')"/>
  </xsl:function>
  
  
  <xsl:function name="tei:dotdot">
    <xsl:param name="index"/>
    <xsl:param name="link"/>
    <!-- dname has telecom/a/b/c/d 
	 and .. should return /a/b/c,		 
    -->
    <xsl:variable name="L2" select="tokenize($dname,'/')"/>
    <xsl:variable name="R">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="for $i in 2 to count($L2)-$index return concat($L2[$i],'/')"/>
      <xsl:value-of select="substring($link,($index*3)+1)"/>
    </xsl:variable>
    <xsl:value-of select="$R"/>
    <xsl:message>echo DOTDOT: <xsl:value-of select="($index,$dname,$R)"/>    </xsl:message>
  </xsl:function>
  </xsl:stylesheet>
  
