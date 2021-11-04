<xsl:stylesheet version="3.0"
                xmlns:xsl =  "http://www.w3.org/1999/XSL/Transform"
		>

  <!--* tangle.xsl:  process a literate program written in SWeb.
      * (To weave, just use swebtohtml.)
      *-->

  <!--* To do:
      * . Test.
      *-->

  <!--* Revisions:
      * 2021-10-03 : CMSMcQ : copy from ~/2000/11/wbs/msm, replace
      * saxon:output with xsl:result-document.  Maybe that's all
      * we need.
      *-->
  
  <xsl:output method="text"
              encoding="utf8"
	      indent="no"
	      />

  <xsl:template match="text()"/>
  
  <xsl:template match="text()" mode="scrap">
    <xsl:choose>
      <xsl:when test="position() = 1 and starts-with(.,'&#xA;')">
	<xsl:value-of select="substring(.,2)"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!--* for each scrap S that has a 'file' attribute, if it is the
      * first scrap with that file name FN, then write it out to 
      * that file, followed first by all scraps with prev=S and then
      * by all scraps with file=FN.
      *--> 
  <xsl:template match="scrap[@file]">
    <xsl:param name="filename" select="@file"/>
    <!--* We are going to need to calculate a better
	* URI to allow execution of this stylesheet from
	* a library directory.  Later.
	*-->
    <xsl:if test="not(./preceding::scrap[@file=$filename])">
      <xsl:message>Writing file <xsl:value-of select="@file"
      /> ... </xsl:message>
      <xsl:result-document href="{$filename}" method="text">
	<xsl:call-template name="scrap"/>
	<xsl:apply-templates mode="file-append" 
			     select="./following::scrap[@file=$filename]"/>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="scrap[@file]" mode="file-append">
    <xsl:call-template name="scrap"/>
  </xsl:template>
  
  <!--* within a scrap, ptr and ref mean recursive embedding *-->
  <xsl:template match="scrap/ptr | scrap/ref" mode="scrap">
    <!--* 
	<xsl:message>Following pointer to <xsl:value-of select="@target"/>:</xsl:message>
	*-->
    <xsl:apply-templates select="id(@target)" mode="scrap"/>
    <!--* 
	<xsl:message>... <xsl:value-of select="@target"/> done.</xsl:message>
	*-->
  </xsl:template>
  
  <xsl:template match="scrap" mode="scrap" name="scrap">
    <xsl:param name="idCur" select="@id"/>
    <xsl:apply-templates mode="scrap"/>
    <!--* if this scrap has an ID, we should now go and fetch all of
	* its continuations, which are the elements which have the 
	* id of this scrap as their prev value 
	*-->
    <xsl:if test="@id">
      <!--
      <xsl:message>Here we should be looking for follow-ons,
      that is scraps with prev="<xsl:value-of select="$idCur"
      />".</xsl:message> -->
      <xsl:apply-templates mode="scrap" 
			   select="/descendant-or-self::scrap[@prev=$idCur]"/>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
