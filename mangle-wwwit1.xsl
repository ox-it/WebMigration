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
      <xsl:apply-templates select="@*|*|processing-instruction()|text()" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="script"/>
  <xsl:template match="link[@rel='stylesheet']"/>
  <xsl:template match="a[@id='departmental-logo']" priority="99"/>
  <xsl:template match="div[@id='secondary-content']"/>
  <xsl:template match="div[@id='breadcrumb']"/>
  <xsl:template match="div[@id='footer']"/>
  <xsl:template match="header"/>
  <xsl:template match="footer"/>
  <xsl:template match="div[@id='header-wrapper']"/>
  <xsl:template match="ul[@id='content-extras']"/>
  <xsl:template match="div[@class='clear']"/>
  <xsl:template match="div[@id='col1']"/>
  <xsl:template match="ul[@class='ym-skiplinks']"/>
  <xsl:template match="ul[@class='pagefurniture']"/>

  <xsl:template
      match="div[tokenize(@class,' ')=('ym-wbox','ym-column','ym-col2','uas-wrapper','teaser','ym-cbox','ym-col3','uas-wrapper','ym-wrapper','wrapper','content')]"
      priority="10">
    <xsl:message>skip div <xsl:value-of select="@class"/></xsl:message>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="div[@id='primary-content']">
    <div id="wrapper">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="html">
    <xsl:copy>
      <xsl:apply-templates
	  select="@*|*|processing-instruction()|text()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="head/title">
    <title>
      <xsl:value-of select="tei:nobsp(.)"/>
    </title>
  </xsl:template>

  <xsl:template match="head">
    <xsl:copy>
      <xsl:apply-templates/>
      <meta name="urlpath" content="{replace(tei:mangleName($fname),'\..*','')}"/>
      <meta name="service" content="Information security"/>
      <meta name="editorial" content="Information security"/>
      <meta name="tit" content="{tei:nobsp(/html/head/title)}"/>
      <meta name="doctype" content="guide"/>
      <meta name="platform" content="generic"/>
      <meta content="IT Services, 13 Banbury Road, Oxford OX2 6NN, United Kingdom" name="DC.Creator"/>
      <meta name="DC.Creator.Address" content="infosec@it.ox.ac.uk"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="meta[@name]">
    <meta name="{@name}" content="{tei:nobsp(@content)}"/>
  </xsl:template>

  <xsl:template match="meta[@name='DC.Date.modified']" priority="99">
    <meta name="updated" content="{tei:bspdate(@content)}" />
  </xsl:template>

  <xsl:template match="body/@class"/>
  <xsl:template match="@class[.='link_xref']"/>
  <xsl:template match="@class[.='link_ref']"/>
  <xsl:template match="@class[.='table']"/>
  <xsl:template match="@class[.='item']"/>
  <xsl:template match="@class[.='link_ptr']"/>
  <xsl:template match="@class[.='link_xptr']"/>

  <xsl:template match="strong/em">
      <xsl:apply-templates select="*|@*|processing-instruction()|text()" />
  </xsl:template>

  <xsl:template match="h1">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=tei:nobsp(/html/head/title)">
	<xsl:message>Kill h1 because its same as title (<xsl:value-of select="."/>)</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="div[@class='page_header']/h1">
    <xsl:element name="{ if (tei:divtype(.)='furthercontent') then
		       'h2' else 'h1'}">
      <xsl:apply-templates select="@*|processing-instruction()|text()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@class[.='maincontent']">
    <xsl:attribute name="class" select="if (tei:divtype(.)='furthercontent') then
		       'furthercontent' else 'maincontent'"/>
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

  <xsl:template match="a[@name]"/>

  <xsl:template match="a[@href]">
    <xsl:copy>
      
      <xsl:attribute name="href">

	<xsl:choose>
	  <xsl:when test="starts-with(@href,'/infosec')">
	    <xsl:value-of select="replace(tei:mangleName(@href),'/infosec','')"/>
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
		<xsl:message>curl -L -s -o <xsl:value-of select="($target,concat('http://www.it.ox.ac.uk/',@href))"/></xsl:message>
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
	      <xsl:when  test="contains(@href,'Site_Manager_workarounds.docx')">
		<xsl:text>/sites/ithelp/files/resources/services_webcms_support_Site_Manager_workarounds.docx</xsl:text>
	      </xsl:when>
	      <xsl:when  test="contains(@href,'TemplateGuide-v10.docx')">
		<xsl:text>/sites/ithelp/files/resources/services_webcms_support_TemplateGuide-v10.docx</xsl:text>
	      </xsl:when>
	      <xsl:when  test="contains(@href,'Web_content_style_guide.pdf')">
		<xsl:text>/sites/ithelp/files/resources/services_webcms_support_Web_content_style_guide.pdf</xsl:text>
	      </xsl:when>
	      <xsl:when test="starts-with(@href,'/')">
		<xsl:value-of select="replace($target,'resources/','/sites/ithelp/files/resources/')"/>
		<xsl:message>curl -L -s -o <xsl:value-of select="($target,concat('http://www.it.ox.ac.uk/',@href))"/></xsl:message>
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

  <xsl:template match="h2|h3">
    <xsl:copy>
      <xsl:if test="preceding-sibling::*[1][self::a/@name]">
	<xsl:attribute name="id">
	  <xsl:value-of
	      select="preceding-sibling::*[1][self::a/@name]/@name"/>
	</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|processing-instruction()|text()">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="div[@class='clear' and @id='em']"/>

  <xsl:template match="img">
    <xsl:variable name="target" select="concat('images/', translate(concat($dirname,'/',tokenize(@src,'/')[last()]),'/','_'))"/>
    <xsl:copy>
      <xsl:attribute name="src"><xsl:value-of select="replace($target,'images/','/sites/ithelp/files/images/')"/></xsl:attribute>
    <xsl:choose>
      <xsl:when test="starts-with(@src,'http')">
	<xsl:message>curl -L -s -o <xsl:value-of select="($target,@src)"/></xsl:message>
      </xsl:when>
      <xsl:when test="starts-with(@src,'/')">
	<xsl:message>curl -L -s -o <xsl:value-of select="($target,concat('http://www.it.ox.ac.uk/',@src))"/></xsl:message>
      </xsl:when>
      <xsl:when test="starts-with(@src,'../images')">
	<xsl:message>curl -L -s -o <xsl:value-of select="($target,concat('http://www.it.ox.ac.uk/',replace(@src,'../images','')))"/></xsl:message>
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
    <xsl:value-of select="replace($in,'services/web/', 'services/webcms/')"/>
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

  <xsl:function name="tei:nobsp" as="xs:string">
    <xsl:param name="text"/>
    <xsl:value-of select="replace($text,', BSP','')"/>
  </xsl:function>

  <xsl:function name="tei:bspdate" as="xs:string">
    <xsl:param name="text"/>
    <xsl:variable name="bits" select="tokenize($text,' ')"/>
    <xsl:value-of select="concat('20',$bits[3],'-',tei:monthnametonumber($bits[2]),'-',$bits[1])"/>
  </xsl:function>

  <xsl:function name="tei:monthnametonumber" as="xs:string">
    <xsl:param name="text"/>
    <xsl:choose>
      <xsl:when test="$text='Jan'">01</xsl:when>
      <xsl:when test="$text='Feb'">02</xsl:when>
      <xsl:when test="$text='Mar'">03</xsl:when>
      <xsl:when test="$text='Apr'">04</xsl:when>
      <xsl:when test="$text='May'">05</xsl:when>
      <xsl:when test="$text='Jun'">06</xsl:when>
      <xsl:when test="$text='Jul'">07</xsl:when>
      <xsl:when test="$text='Aug'">08</xsl:when>
      <xsl:when test="$text='Sep'">09</xsl:when>
      <xsl:when test="$text='Oct'">10</xsl:when>
      <xsl:when test="$text='Nov'">11</xsl:when>
      <xsl:when test="$text='Dec'">12</xsl:when>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>

