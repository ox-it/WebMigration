<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
		xmlns:xs="http://www.w3.org/2001/XMLSchema" 
		xpath-default-namespace="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		exclude-result-prefixes="xs tei"
		version="2.0">
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
  <xsl:param name="fname"/>
  <xsl:param name="dirname"/>
  <xsl:param name="basename"/>
  <xsl:template match="/">
    <xsl:variable name="outname"
		  select="tei:mangleName(replace($fname,'\.html',''))"/>
    <xsl:result-document href="{$outname}.html">
      <xsl:message>From <xsl:value-of select="$fname"/> write <xsl:value-of select="$outname"/>.html</xsl:message>
      <xsl:apply-templates/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|processing-instruction()|comment()|text()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="script[@src]"/>
  <xsl:template match="link[@rel='stylesheet']"/>
  <xsl:template match="div[@id='footer']"/>
  <xsl:template match="div[@id='hdr']"/>
  <xsl:template match="div[@class='sidecol']"/>
  <xsl:template match="div[@id='logoOuter']"/>
  <xsl:template match="div[@id='mainMenu']"/>
  <xsl:template match="div[@class='float-wrapper']">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="div[@class='main-content' or @id='col-a' or
		       @class='rh-col' or @id='columns' or
		       @class='cols-wrapper' or @class='show-all']">
    <xsl:apply-templates/>
  </xsl:template>
         
  <xsl:template match="html">
    <xsl:copy>
      <xsl:apply-templates
	  select="@*|*|processing-instruction()|comment()|text()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="head">
    <xsl:copy>
      <xsl:apply-templates/>
      <meta name="urlpath" content="{replace($fname,'\..*','')}"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="meta[@name='service' and @content='']">
    <meta name="service" content="{tokenize(replace($fname,'\..*',''),'/')[1]}"/>
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
		<xsl:apply-templates select="current-group()[starts-with(local-name(),'h')]"/>
		<xsl:apply-templates select="current-group()[not(starts-with(local-name(),'h'))]"/>
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
		<xsl:apply-templates select="current-group()"/>
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
		<xsl:apply-templates select="current-group()"/>
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
	      test="starts-with(@href,'/itlp/')">
	    <xsl:text>http://courses.it.ox.ac.uk/</xsl:text>
	  </xsl:when>
	  <xsl:when
	      test="starts-with(@href,'https://www.oucs.ox.ac.uk/') or starts-with(@href,'http://www.oucs.ox.ac.uk/')">
	    <xsl:value-of select="replace(tei:mangleName(substring-after(@href,'//www.oucs.ox.ac.uk')) ,'/$','/index')"/>
	  </xsl:when>
	  <xsl:when test="@href='mailto:help@oucs.ox.ac.uk'">
	    <xsl:text>mailto:help@it.ox.ac.uk</xsl:text>
	  </xsl:when>
	  <xsl:when test="starts-with(@href,'http') or
			  starts-with(@href,'ftp') or
			  starts-with(@href,'mailto')">
	    <xsl:value-of select="@href"/>
	  </xsl:when>
	  <xsl:when  test="matches(@href,'(gif|jpeg|jpg|png)$')">
	    <xsl:variable name="target" select="concat('images/', translate(concat($dirname,'/',tokenize(@href,'/')[last()]),'/','_'))"/>
	    <xsl:choose>
	      <xsl:when test="starts-with(@href,'/')">
		<xsl:value-of select="replace($target,'images/','/sites/ithelp/files/images/')"/>
		<xsl:message>curl -s -o <xsl:value-of select="($target,concat('http://www.oucs.ox.ac.uk',@href))"/></xsl:message>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="replace($target,'images/','/sites/ithelp/files/images/')"/>
		<xsl:message>cp <xsl:value-of select="(concat($dirname,'/',@href),$target)"/></xsl:message>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:when  test="matches(@href,'(pub|indd|ai|psd|doc|docx|ppt|pptx|pdf)$')">
	    <xsl:variable name="target" select="concat('resources/', translate(concat($dirname,'/',tokenize(@href,'/')[last()]),'/','_'))"/>
	    <xsl:choose>
	      <xsl:when test="starts-with(@href,'/')">
		<xsl:value-of select="replace($target,'resources/','/sites/ithelp/files/resources/')"/>
		<xsl:message>curl -s -o <xsl:value-of select="($target,concat('http://www.oucs.ox.ac.uk',@href))"/></xsl:message>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="replace($target,'resources/','/sites/ithelp/files/resources/')"/>
		<xsl:message>cp <xsl:value-of select="(concat($dirname,'/',@href),$target)"/></xsl:message>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="replace(tei:mangleName(@href),'/$','/index')"/>
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

  <xsl:template match="comment()"/>
  <xsl:template match="@id">
    <xsl:attribute name="id" select="replace(.,'body.1_','')"/>
  </xsl:template>

  <xsl:template match="@*|processing-instruction()|text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="div[@class='clear' and @id='em']"/>

  <xsl:template match="div[@id='breadcrumb']"/>

  <xsl:template match="img">
    <xsl:variable name="target" select="concat('images/', translate(concat($dirname,'/',tokenize(@src,'/')[last()]),'/','_'))"/>
    <xsl:copy>
      <xsl:attribute name="src"><xsl:value-of select="replace($target,'images/','/sites/ithelp/files/images/')"/></xsl:attribute>
    <xsl:choose>
      <xsl:when test="starts-with(@src,'http')">
	<xsl:message>curl -s -o <xsl:value-of select="($target,@src)"/></xsl:message>
      </xsl:when>
      <xsl:when test="starts-with(@src,'/')">
	<xsl:message>curl -s -o <xsl:value-of select="($target,concat('http://www.oucs.ox.ac.uk',@src))"/></xsl:message>
      </xsl:when>
      <xsl:when test="starts-with(@src,'../images')">
	<xsl:message>curl -s -o <xsl:value-of select="($target,concat('http://www.oucs.ox.ac.uk',replace(@src,'../images','')))"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:message>cp <xsl:value-of select="(concat($dirname,'/',@src),$target)"/></xsl:message>
      </xsl:otherwise>
	</xsl:choose>
      <xsl:apply-templates select="@*[not(name()='src')]"/>
    </xsl:copy>

  </xsl:template>

  <xsl:function name="tei:mangleName" as="xs:string">
    <xsl:param name="in"/>
    <xsl:variable name="out">
      <xsl:analyze-string select="$in" regex="^(\./)?(.*).xml\?ID=([^#]*)(#.*)?$">
	<xsl:matching-substring>
	  <xsl:choose>
	    <xsl:when test="regex-group(2)=$basename">#</xsl:when>
	    <xsl:when test="concat(regex-group(2),'.xml')=$basename">#</xsl:when>
	    <xsl:when test="regex-group(4)=''">
	      <xsl:value-of select="regex-group(2)"/>
	      <xsl:text>#</xsl:text>
	   </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="regex-group(2)"/>
	      <xsl:text>-</xsl:text>
	    </xsl:otherwise>
	  </xsl:choose>
	  <xsl:value-of select="tei:xml2html(regex-group(3))"/>
	  <xsl:value-of select="tei:xml2html(regex-group(4))"/>
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
    <xsl:sequence select="replace(replace(replace($text,'.xml.html',''),'.xml',''),'body.1_','')"/>
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

