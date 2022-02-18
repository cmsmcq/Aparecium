<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xsd="http://www.w3.org/2001/XMLSchema"
		version="3.0" 
		>

  <xsl:output method="xhtml"
	      indent="yes"
	      />

  <xsl:variable name="bar-width" as="xsd:double" select="20"/>
  
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
	<title>Timing data</title>
	<style type="text/css">
	  td { text-align: right; padding: 0 0.3em; }
	  span.total { display: inline-block; width: <xsl:value-of select="$bar-width"/>em; }
	  span.rec   { display: inline-block; background-color: blue; float: left; }
	  span.tree  { display: inline-block; background-color: green; float: right; }
	</style>
      </head>
      <body>
	<xsl:apply-templates/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="test-set">
    <h3 xmlns="http://www.w3.org/1999/xhtml"><xsl:value-of select="@name"/></h3>
    <table xmlns="http://www.w3.org/1999/xhtml">
      <col width="20%"/>
      <col width="20%"/>
      <col width="20%"/>
      <col width="40%"/>
      <thead>
	<tr>
	  <td>Outer</td>
	  <td>Recognition</td>
	  <td>Tree building</td>
	  <td>&#xA0;</td>
	</tr>	  
      </thead>
      <tbody>
	<xsl:apply-templates/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="test-case">
    <xsl:variable name="outer" as="xsd:double" select="(@outer/number(), 
                                                       (number(@rec) + number(@tree)), 
                                                       100000)[1]"/>
    <xsl:variable name="rec"   as="xsd:double" select="(@rec/number(), 0)[1]"/>
    <xsl:variable name="tree"  as="xsd:double" select="(@tree/number(),0)[1]"/>
    
    <tr xmlns="http://www.w3.org/1999/xhtml">
      <td><xsl:sequence select="@outer/string()"/></td> 
      <td><xsl:sequence select="@rec/string()"/>
      (<xsl:sequence select="format-number(100 * $rec div $outer, '99.9')"/>%)
      </td>
      <td><xsl:sequence select="@tree/string()"/>
      (<xsl:sequence select="format-number(100 * $tree div $outer, '09.9')"/>%)
      </td>
      <td>
	<span class="total">
	  <span class="rec" style="width: {$bar-width * $rec div $outer}em;">&#xA0;</span>
	  <span class="tree" style="width: {$bar-width * $tree div $outer}em;">&#xA0;</span>
	</span>
      </td>
    </tr>
  </xsl:template>
  
</xsl:stylesheet>
