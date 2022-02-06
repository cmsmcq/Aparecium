<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:p5="http://www.tei-c.org/ns/1.0"
		xmlns:xh="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		version="1.0">

  <xsl:import href="http://blackmesatech.com/lib/swebtohtml.xsl"/> 
  <!-- <xsl:import href="../../../../blackmesatech.com/lib/swebtohtml.xsl"/> -->
  
  <xsl:output encoding="us-ascii"
	      method="html"/>

  <xsl:variable name="siteroot" select="'..'"/>
  <xsl:variable name="xhtmlns" select=" 'http://www.w3.org/1999/xhtml' "/>
  
  <xsl:template name="inject-css-link">
    <xsl:element name="link" namespace="{$xhtmlns}">
      <xsl:attribute name="rel">stylesheet</xsl:attribute>
      <xsl:attribute name="href">../lib/local.css</xsl:attribute>
    </xsl:element>
  </xsl:template>    
 
</xsl:stylesheet>
