<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" 
		xpath-default-namespace="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xs tei"
		version="2.0">
  <xsl:output indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
  <xsl:param name="fname"/>
  <xsl:param name="dirname"/>
  <xsl:param name="basename"/>
  <xsl:template match="/">
    <xsl:variable name="outname"
		  select="tei:mangleName(replace($fname,'.html',''))"/>
    <xsl:result-document href="{$outname}">
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|processing-instruction()|comment()|text()" />
    </xsl:copy>
  </xsl:template>
  <xsl:template match="/html">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|processing-instruction()|comment()|text()" />
      <xsl:copy-of select="//processing-instruction()[name(.)='divnumber']"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@class[.='link_xref']"/>
  <xsl:template match="@class[.='link_ref']"/>
  <xsl:template match="@class[.='table']"/>
  <xsl:template match="@class[.='item']"/>
  <xsl:template match="@class[.='link_ptr']"/>
  <xsl:template match="@class[.='link_xptr']"/>

  <xsl:template match="div[@class='page_header']/h1">
    <xsl:element name="{ if (tei:divtype(.)='furthercontent') then
		       'h2' else 'h1'}">
      <xsl:apply-templates select="@*|processing-instruction()|comment()|text()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@class[.='maincontent']">
    <xsl:attribute name="class" select="if (tei:divtype(.)='furthercontent') then
		       'furthercontent' else 'maincontent'"/>
  </xsl:template>

  <xsl:template match="div[@class='page_body']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
        <xsl:for-each-group select="*"
			    group-starting-with="div[starts-with(@class,'teidiv')]">
          <xsl:choose>
            <xsl:when test="self::div[starts-with(@class,'teidiv')]">
	      <xsl:apply-templates select="current-group()"/>
            </xsl:when>
            <xsl:otherwise>
	      <div class="body_{if (tei:divtype(.)='furthercontent') then
		       'furthercontent' else 'maincontent'}">
		<xsl:apply-templates select="current-group()[starts-with(local-name(),'h')]"/>
		<xsl:apply-templates select="current-group()[not(starts-with(local-name(),'h'))]"/>
	      </div>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="h2[string-length(.)=0]"/>

  <xsl:template match="div[@class='p']">
    <xsl:for-each-group select="node()" group-starting-with="ol|ul|dl">
      <xsl:choose>
	<xsl:when test="self::ol|self::ul|self::dl">
	  <xsl:apply-templates select="current-group()"/>
	</xsl:when>
	<xsl:otherwise>
	  <p>
	    <xsl:apply-templates select="current-group()"/>
	  </p>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="div[@class='teidiv0']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
        <xsl:for-each-group select="*" group-starting-with="div[starts-with(@class,'teidiv')]">
          <xsl:choose>
            <xsl:when test="self::div[starts-with(@class,'teidiv')]">
	      <xsl:apply-templates select="current-group()"/>
            </xsl:when>
            <xsl:otherwise>
	      <div class="div0_firstcontent">
		<xsl:apply-templates select="current-group()"/>
	      </div>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="div[@class='teidiv1']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
        <xsl:for-each-group select="*" group-starting-with="div[starts-with(@class,'teidiv')]">
          <xsl:choose>
            <xsl:when test="self::div[starts-with(@class,'teidiv')]">
	      <xsl:apply-templates select="current-group()"/>
            </xsl:when>
            <xsl:otherwise>
	      <div class="div1_firstcontent">
		<xsl:apply-templates select="current-group()"/>
	      </div>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="a[@href]">
    <xsl:copy>
      <xsl:attribute name="href">
	<xsl:choose>
	  <xsl:when
	      test="starts-with(@href,'http://www.oucs.ox.ac.uk/')">
	    <xsl:value-of select="tei:mangleName(substring-after(@href,'http://www.oucs.ox.ac.uk'))"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@href,'http') or
			  starts-with(@href,'ftp') or
			  starts-with(@href,'mailto')">
	    <xsl:value-of select="@href"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="tei:mangleName(@href)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="@*[not(name()='href')]" />
      <xsl:choose>
	<xsl:when test=".=$basename">
	  <xsl:value-of select="/html/head/title"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="*|text()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()|@*|processing-instruction()|text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="div[@class='clear' and @id='em']"/>

  <xsl:template match="div[@class='tocBody']">	
    <xsl:if test="not(tei:divtype(.)='furthercontent')">
      <xsl:copy>
	<xsl:apply-templates select="@*|*"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="img">
    <xsl:copy>
      <xsl:attribute name="src">
	<xsl:choose>
	  <xsl:when test="not(contains(@src,'/'))">
	    <xsl:value-of select="@src"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@src,'http')">
	    <xsl:value-of select="@src"/>
	  </xsl:when>
	  <xsl:when test="starts-with(@src,'/')">
	    <xsl:value-of select="tokenize(@src,'/')[last()]"/>
	    <xsl:message>curl -s -o <xsl:sequence select="concat($dirname,'/',tokenize(@src,'/')[last()],' http://www.oucs.ox.ac.uk',@src)"/></xsl:message>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="tokenize(@src,'/')[last()]"/>
	    <xsl:message>mv <xsl:sequence  select="concat($dirname,'/',@src,' ',$dirname,'/',tokenize(@src,'/')[last()])"/></xsl:message>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="@*[not(name()='src')]"/>
    </xsl:copy>
  </xsl:template>

  <xsl:function name="tei:mangleName" as="xs:string">
    <xsl:param name="in"/>
    <xsl:variable name="out">
      <xsl:analyze-string select="$in" regex="^(.*).xml\?ID=([^#]*)(#.*)?$">
	<xsl:matching-substring>
	  <xsl:value-of select="regex-group(1)"/>
	  <xsl:text>-</xsl:text>
	  <xsl:value-of select="tei:xml2html(regex-group(2))"/>
	  <xsl:text>.html</xsl:text>
	  <xsl:value-of select="tei:xml2html(regex-group(3))"/>
	</xsl:matching-substring>
	<xsl:non-matching-substring>
	  <xsl:value-of select="tei:xml2html($in)"/>
	</xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:value-of select="$out"/>
  </xsl:function>

  <xsl:function name="tei:xml2html" as="xs:string">
    <xsl:param name="text"/>
    <xsl:sequence select="replace(replace(replace($text,'.xml.html','.html'),'.xml','.html'),'body.1_','')"/>
  </xsl:function>



  <xsl:template match="processing-instruction()[name(.)='divtype']"/>
  <!--
      <xsl:template match="processing-instruction()[name(.)='divnumber']"/>
  -->
  <xsl:function name="tei:divtype" as="xs:string">
    <xsl:param name="context"/>
    <xsl:for-each select="$context">
      <xsl:value-of select="//processing-instruction()[name(.)='divtype'][1]"/>
    </xsl:for-each>
  </xsl:function>
</xsl:stylesheet>
