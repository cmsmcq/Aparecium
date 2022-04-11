<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:p5="http://www.tei-c.org/ns/1.0"
		xmlns:xh="http://www.w3.org/1999/xhtml"

		version="1.0">

  <xsl:import href="../lib/swebtohtml.xsl"/> 
  <!-- <xsl:import href="http://blackmesatech.com/lib/swebtohtml.xsl"/>  -->
  <!-- <xsl:import href="../../../../blackmesatech.com/lib/swebtohtml.xsl"/> -->
  
  <xsl:output encoding="us-ascii"
	      method="html"/>

  <xsl:variable name="siteroot" select="'..'"/>
  <xsl:variable name="xhtmlns" select=" 'http://www.w3.org/1999/xhtml' "/>
  
  <!-- <xsl:template name="inject-css-link"> this name doesn't work -->
  <!-- <xsl:template name="additional-css-styles"> needs text data -->
  <xsl:template name="additional-html-head-elements">
    <xsl:element name="link" namespace="{$xhtmlns}">
      <xsl:attribute name="rel">stylesheet</xsl:attribute>
      <xsl:attribute name="href">../lib/local.css</xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="div/head[ancestor::body]" priority="10">
    <xsl:variable name="depth" select="count(ancestor::div)"/>
    <xsl:call-template name="make-left-up-right-arrows"/>
    
    <xsl:element name="h{1 + $depth}">
      <xsl:if test="parent::*[@rend='comment']">
	<xsl:attribute name="class">comment</xsl:attribute>
      </xsl:if>
      <xsl:element name="a">
	<xsl:attribute name="class">selflink</xsl:attribute>
	<xsl:call-template name="make-name-.."/>
	<xsl:for-each select=".."><xsl:call-template name="make-href-to-current"/></xsl:for-each>
	<xsl:if test="ancestor::body">
	  <xsl:number level="multiple" count="div1|div2|div3|div4|div" format="1. "/>
	</xsl:if>
      </xsl:element>
      <xsl:apply-templates/>
    </xsl:element>

    <!--* If we have children, make mini-toc *-->
    <xsl:if test="../div">
      <xsl:element name="ul">
	<xsl:apply-templates select="../div" mode="minitoc"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="div" mode="minitoc">
    <xsl:element name="li">
      <xsl:number level="multiple" count="div" format="1.1. "/>
      <xsl:element name="a">
	<xsl:call-template name="make-href-to-current"/>
	<xsl:apply-templates select="head" mode="toc"/>
      </xsl:element>

      <!--* If we have children, make mini-toc *-->
      <xsl:if test="./div">
	<xsl:element name="ul">
	  <xsl:apply-templates select="./div" mode="minitoc"/>
	</xsl:element>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!--* as an experiment, make arrows pointing left, up, and right to
       float to the right of each heading *-->
  <xsl:template name="make-left-up-right-arrows">
    <xsl:element name="div">
      <xsl:attribute name="class">
	<xsl:text>quicknav</xsl:text>
      </xsl:attribute>
      
      <!--* left-arrow *-->
      <xsl:call-template name="make-quicknav-pointer">
	<xsl:with-param name="target-div"
			select="parent::div/preceding-sibling::div[1]"/>
	<xsl:with-param name="symbol"
			select="'&#x23F4;'"/>
      </xsl:call-template>
      <!-- 23EA double-triangle
	   23F4 single (preferred by Unicode to C0?)
	   23C0 single black (shunned?)
	   23C1 single white
	   23C2 single black small
	   23C3 single white small
      -->
      
      <!--* up-arrow *-->
      <xsl:call-template name="make-quicknav-pointer">
	<xsl:with-param name="target-div"
			select="parent::div/parent::div[1]"/>
	<xsl:with-param name="symbol"
			select="'&#x23F6;'"/>
	<xsl:with-param name="default-pointer"
			select="'#toc'"/>
      </xsl:call-template>

      <!-- 23EB double-triangle
	   23F6 single (preferred by Unicode to C0?)
	   23B2 single black (shunned?)
	   23B3 single white
	   23B4 single black small
	   23B5 single white small
      -->

      <!--* right-arrow *-->
      <xsl:call-template name="make-quicknav-pointer">
	<xsl:with-param name="target-div"
			select="parent::div/following-sibling::div[1]"/>
	<xsl:with-param name="symbol"
			select="'&#x23F5;'"/>
      </xsl:call-template>
      <!-- 23E9 double-triangle
	   23F5 single (preferred by Unicode to C0?)
	   23B6 single black (shunned?)
	   23B7 single white
	   23B8 single black small
	   23B9 single white small
      -->

    </xsl:element>
  </xsl:template>

  <xsl:template name="make-quicknav-pointer">
    <xsl:param name="target-div" required="no"/>
    <xsl:param name="symbol" required="yes"/>
    <xsl:param name="default-pointer" required="no"/>


    <xsl:element name="span">
      <xsl:attribute name="class">arrow</xsl:attribute>
      <xsl:choose>
	<xsl:when test="(count($target-div) > 0) or ($default-pointer)">
	  <xsl:element name="a">
	    <xsl:choose>
	      <xsl:when test="count($target-div) > 0">
		<xsl:for-each select="$target-div">
		  <xsl:call-template name="make-href-to-current"/>
		</xsl:for-each>
	      </xsl:when>
	      <xsl:when test="not($default-pointer = '')">
		<xsl:attribute name="href">
		  <xsl:value-of select="$default-pointer"/>
		</xsl:attribute>
	      </xsl:when>
	      <xsl:otherwise>
	      </xsl:otherwise>
	    </xsl:choose>
	    <xsl:value-of select="$symbol"/>
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>&#xA0;</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
 
</xsl:stylesheet>
