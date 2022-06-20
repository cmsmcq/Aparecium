<!DOCTYPE xsl:stylesheet [
<!--* 
<!DOCTYPE xsl:stylesheet PUBLIC 'http://www.w3.org/1999/XSL/Transform' 
      './xslt10.dtd' [
*-->

<!ATTLIST xsl:stylesheet xmlns:xsl CDATA "http://www.w3.org/1999/XSL/Transform" >

<!ENTITY lt     "&#38;#60;"      ><!--=less-than sign R:-->
<!ENTITY gt     ">"      ><!--=greater-than sign R:-->
<!ENTITY ldquo "&#8220;"><!-- left double quotation mark,
                              U+201C ISOnum -->
<!ENTITY rdquo "&#8221;"><!-- right double quotation mark,
                              U+201D ISOnum -->
<!ENTITY lsquo "&#8216;">
<!ENTITY rsquo "&#8217;">
<!ENTITY nbsp "&#160;">
<!ENTITY ltri   "&#x25C3;" ><!--/triangleleft B: l triangle, open-->
<!ENTITY rtri   "&#x25B9;" ><!--/triangleright B: r triangle, open-->
<!ENTITY equiv  "&#x2261;" ><!--/equiv R: =identical with-->
<!ENTITY rarr   "&#x2192;" ><!--/rightarrow /to A: =rightward arrow-->



<!ENTITY lab "&#x3008;"> <!--* left angle bracket, in Unicode *-->
<!ENTITY rab "&#x3009;"> <!--* right angle bracket, in Unicode *-->
<!ENTITY lab "&#x300A;"> <!--* left double angle bracket *-->
<!ENTITY rab "&#x300B;"> <!--* right double angle bracket *-->
<!--* alternatives *-->
<!ENTITY lab "&#x2329;"> <!--* left pointing angle bracket, in Unicode *-->
<!ENTITY rab "&#x232A;"> <!--* right pointing angle bracket, in Unicode *-->
<!ENTITY lab "&#x276C;"> <!--* medium left pointing angle bracket ornament, in Unicode *-->
<!ENTITY rab "&#x276D;"> <!--* medium right pointing angle bracket ornament, in Unicode *-->
<!ENTITY lab "&#x2770;"> <!--* heavy left pointing angle bracket ornament, in Unicode *-->
<!ENTITY rab "&#x2771;"> <!--* heavy right pointing angle bracket ornament, in Unicode *-->
<!ENTITY lab "&#x27E8;"> <!--* mathematical left angle bracket *-->
<!ENTITY rab "&#x27E9;"> <!--* mathematical right angle bracket *-->
<!ENTITY lab "&#x27EA;"> <!--* mathematical left double angle bracket *-->
<!ENTITY rab "&#x27EB;"> <!--* mathematical right double angle bracket *-->

<!ENTITY sd.left  "&lab;"> <!--* scrap definition left bracket *-->
<!ENTITY sd.right "&rab;"> <!--* scrap definition right bracket *-->

<!ENTITY scrapref.left  "&lab;"> <!--* scrap reference left bracket (generic) *-->
<!ENTITY scrapref.right "&rab;"> <!--* scrap reference right bracket (generic) *-->

<!ENTITY cr.left  "&scrapref.left;"> <!--* scrap continuation reference left bracket *-->
<!ENTITY cr.right "&scrapref.right;"> <!--* scrap continuation reference right bracket *-->
<!ENTITY uir.left  "&scrapref.left;"> <!--* scrap used-in reference left bracket *-->
<!ENTITY uir.right "&scrapref.right;"> <!--* scrap used-in reference right bracket *-->
<!ENTITY fr.left  "&scrapref.left;"> <!--* scraps by file reference left bracket *-->
<!ENTITY fr.right "&scrapref.right;"> <!--* scraps by file reference right bracket *-->
<!ENTITY sr.left  "&scrapref.left;"> <!--* scrap/ptr reference left bracket *-->
<!ENTITY sr.right "&scrapref.right;"> <!--* scrap/ref reference right bracket *-->

<!ATTLIST xsl:text xmlns:xsl CDATA #IMPLIED>
<!ENTITY txtnl "<xsl:text xmlns:xsl='http://www.w3.org/1999/XSL/Transform'>&#xA;</xsl:text>">
]>
<xsl:stylesheet 
		version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

 <xsl:import href="tltohtml.xsl"/> 
 <!--* 
 <xsl:import href="http://www.w3.org/People/cmsmcq/lib/tltohtml.xsl"/>
 *-->

 <!--* If retain-ids = true, then use the IDs in the source as 
     * IDs in the output.  This is dangerous in theory and
     * safe in practice for IDs generated by humans.  If
     * retain-ids = false, generate new ones regardless *-->
 <xsl:param name="retain-ids">true</xsl:param>

 <xsl:param name="msgkw">terse</xsl:param>
 <xsl:variable name="silent">0</xsl:variable>
 <xsl:variable name="terse">1</xsl:variable>
 <xsl:variable name="verbose">2</xsl:variable>
 <xsl:variable name="debug">3</xsl:variable>
 <xsl:variable name="msglvl">
  <xsl:choose>
   <xsl:when test="$msgkw='silent'"><xsl:value-of select="$silent"/></xsl:when>
   <xsl:when test="$msgkw='terse'"><xsl:value-of select="$terse"/></xsl:when>
   <xsl:when test="$msgkw='verbose'"><xsl:value-of select="$verbose"/></xsl:when>
   <xsl:when test="$msgkw='debug'"><xsl:value-of select="$debug"/></xsl:when>
   <xsl:otherwise><xsl:value-of select="$terse"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>

 <xsl:template name="additional-css-styles">
  div.scrap {
    margin-top: 0.5em; 
    background-color: #CFEFCF; 
    background-color: #E7F7E7; 
    padding: 0.6em;
    margin-bottom: 0.5em;
  }
  pre.scrapbody {
    margin-left: 0.5em; 
    margin-bottom: 0.5em;
  }
  span.scrapcontinuations {
    font-size:smaller; 
  }
  span.scrapinbound {
    font-size:smaller;
  }
  span.scrapref {
    display: inline-block;
    text-indent: -0.3em;
    font-family: New Times Roman, serif, Lucida Sans Unicode;
  }
  em.scrapptr {
    font-family: New Times Roman, serif, Lucida Sans Unicode;
  }
  dl.desclist {
    list-style-type: none;
  }
  dl.desclist > dt {
    display: run-in;
    padding-right: 0.5em;
/*
*/
  }
  dl.desclist > dd {
    text-indent: -1em;
    margin-left: 1em; 
  }
  ul.desclist { 
    list-style-type: none;
  }
  ul.desclist > li {
    margin-left: 2em;
    text-indent: -2em;
  }
  div.epigraph .Real-P {margin-top: 0em; margin-bottom: 0em;} 
  <xsl:call-template name="sweb-additional-css-styles"/>
 </xsl:template>
 
 <!--* Born to be overridden *-->
 <xsl:template name="sweb-additional-css-styles"/>

 <!--* versionList *-->
 <xsl:template match="versionList">
   <xsl:element name="div">
     <xsl:attribute name="class">
       <xsl:text>versionList</xsl:text>
     </xsl:attribute>
     <xsl:element name="p">
       <xsl:text>Versions defined:</xsl:text>
     </xsl:element>
     <xsl:element name="ul">
       <xsl:apply-templates/>
     </xsl:element>
   </xsl:element>
 </xsl:template>
 <xsl:template match="versionList/version">
   <xsl:element name="li">
     <xsl:attribute name="id">
       <xsl:value-of select="@id"/>
     </xsl:attribute>
     <xsl:attribute name="class">
       <xsl:text>versionentry</xsl:text>
     </xsl:attribute>
     <xsl:element name="em">
       <xsl:value-of select="@id"/>
       <xsl:text>:</xsl:text>
     </xsl:element>
     <xsl:text>&#xA0;</xsl:text>
     <xsl:apply-templates/>
     <xsl:apply-templates select="@fallback"/>
   </xsl:element>
 </xsl:template>

 <xsl:template match="versionList/version/@fallback">
   <xsl:text> (falls back to </xsl:text>
   <xsl:value-of select="."/>
   <xsl:text>)</xsl:text>
 </xsl:template>
 
 <!--* scraps *-->
 <xsl:template match="scrap">
   <xsl:if test="$msglvl >= $verbose">
     <xsl:message>Doing scrap "<xsl:value-of select="@name"/>" ...</xsl:message>
   </xsl:if>
   
   <xsl:element name="div">
     <xsl:attribute name="class">scrap</xsl:attribute>
     <!--* <xsl:attribute name="style">margin-top: 1em; background-color: #BADABA</xsl:attribute> *-->
     
     <!--* 1 Scrap heading *-->
     <xsl:element name="span"><!--* or: strong *-->
       <xsl:element name="a">
	 <xsl:attribute name="name">
	   <xsl:choose>
	     <xsl:when test="@id and $retain-ids = 'true'"><xsl:value-of select="@id"/></xsl:when>
	     <xsl:otherwise><xsl:value-of select="generate-id(.)"/></xsl:otherwise>
	   </xsl:choose>
	 </xsl:attribute>
	 <xsl:text>&sd.left; </xsl:text>
	 <xsl:call-template name="getscrapnum"/>
	 <xsl:text> </xsl:text>
	 <xsl:value-of select="@name"/>
	 <xsl:if test="@file">
	   <xsl:text> [File </xsl:text>
	   <xsl:value-of select="@file"/>
	   <xsl:text>] </xsl:text>
	 </xsl:if>
	 <xsl:if test="@prev">
	   <xsl:text> [continues </xsl:text>
	   <xsl:element name="a">
	     <xsl:attribute name="href">
	       <xsl:text>#</xsl:text>
	       <xsl:choose>
		 <xsl:when test="$retain-ids = 'true'"><xsl:value-of select="@prev"/></xsl:when>
		 <xsl:otherwise><xsl:value-of select="generate-id(id(@prev))"/></xsl:otherwise>
	       </xsl:choose>
	     </xsl:attribute>
	     <xsl:apply-templates select="id(@prev)" mode="getscrapnumref"/>
	   </xsl:element>
	   <!--* should put in a forward pointer, too, ... *-->
	   <xsl:text>] </xsl:text>
	 </xsl:if>
	 <xsl:text> &sd.right; </xsl:text>
	 <xsl:apply-templates mode="scrap-head-version-info" select="@version"/>
	 <xsl:text> &equiv;</xsl:text>
       </xsl:element>
     </xsl:element>
     &txtnl;
     
     <!--* 2 Scrap body *-->
     <xsl:element name="pre">
       <xsl:attribute name="class">scrapbody</xsl:attribute>
       <xsl:apply-templates/>
     </xsl:element>
     &txtnl;
     
     <!--* 3 Scrap trailer:  related scraps *-->
     <xsl:call-template name="getcontinuations">
       <xsl:with-param name="headofchain" select="@id"/>
     </xsl:call-template>
     &txtnl;
     <xsl:call-template name="getinbound">
       <xsl:with-param name="calledscrap" select="@id"/>
     </xsl:call-template>
     &txtnl;
   </xsl:element>
   &txtnl;
   
   <xsl:if test="$msglvl>=$debug">
     <xsl:message> ... done with scrap "<xsl:value-of select="@name"/>".</xsl:message>
   </xsl:if>
 </xsl:template>

 <xsl:template mode="scrap-head-version-info"
	       match="@version">
   <xsl:text>(for version </xsl:text>
   <xsl:element name="em">
     <xsl:value-of select="."/>
   </xsl:element>
   <xsl:text>)</xsl:text>
 </xsl:template>
 

 <!--* Named templates for getting references to scraps *-->
 <xsl:template name="getscrapnum" mode="getscrapnum" match="scrap">
  <xsl:number level="any" from="/" count="scrap"/>
 </xsl:template>

 <xsl:template name="getscrapref" mode="getscrapref" match="scrap">
  <xsl:choose>
   <xsl:when test="./@name">
    <xsl:value-of select="@name"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:if test="./@file">
     <xsl:text>[File </xsl:text>
     <xsl:value-of select="@file"/>
     <xsl:text>]</xsl:text>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
  <xsl:text> </xsl:text>

  <xsl:if test="@version">
    <xsl:text> (v. </xsl:text>
    <xsl:value-of select="@version"/>
    <xsl:text>) </xsl:text>
  </xsl:if>
  <!--*
    <xsl:if test="@file">
      <xsl:text> [File </xsl:text>
        <xsl:value-of select="@file"/>
      <xsl:text>] </xsl:text>
    </xsl:if>
  *-->
  <xsl:number level="any" from="/" count="scrap"/>
 </xsl:template>

 <xsl:template name="getscrapnumref" mode="getscrapnumref" match="scrap">
  <xsl:number level="any" from="/" count="scrap"/>
  <xsl:text> </xsl:text>
  <xsl:choose>
   <xsl:when test="./@name">
    <xsl:value-of select="@name"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:if test="./@file">
     <xsl:text>[File </xsl:text>
     <xsl:value-of select="@file"/>
     <xsl:text>]</xsl:text>
    </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--* Named templates for getting lists of related scraps *-->
  <xsl:template name="getcontinuations">
  <xsl:param name="headofchain">foo</xsl:param>
  
  <xsl:element name="span">
   <xsl:attribute name="class">scrapcontinuations</xsl:attribute>
   <xsl:choose>
    <xsl:when test="//scrap[@prev=$headofchain]">
     <xsl:text>Continued in </xsl:text>
     <xsl:for-each select="//scrap[@prev=$headofchain]">
      <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
      <xsl:text>&cr.left;</xsl:text>
      <xsl:element name="a">
       <xsl:call-template name="make-href-to-current"/>
       <xsl:apply-templates select="." mode="getscrapref"/>
      </xsl:element>
      <xsl:text>&cr.right;</xsl:text>
     </xsl:for-each>
     <xsl:element name="br"/>
    </xsl:when>
    <xsl:otherwise></xsl:otherwise>
   </xsl:choose>
  </xsl:element>&txtnl;
 </xsl:template>
 
 <xsl:template name="getinbound">
   <xsl:param name="calledscrap">foo</xsl:param>

   <!--* first, equivalents *-->
   <xsl:element name="span">
     <xsl:attribute name="class">scrapinbound</xsl:attribute>
     
     <xsl:choose>
       <xsl:when test="//scrap[@corresp=$calledscrap]">
	 <xsl:text>Other versions of this code are in </xsl:text>
	 <xsl:for-each select="//scrap[@corresp=$calledscrap]">
	   <xsl:text>&uir.left; </xsl:text>
	   <xsl:element name="a">
	     <xsl:attribute name="href">
	       <xsl:text>#</xsl:text>
	       <xsl:choose>
		 <xsl:when test="@id and $retain-ids = 'true'">
		   <xsl:value-of select="@id"/>
		 </xsl:when>
		 <xsl:otherwise>
		   <xsl:value-of select="generate-id(.)"/>
		 </xsl:otherwise>
	       </xsl:choose>
	     </xsl:attribute>
	     <xsl:apply-templates select="." mode="getscrapref"/>
	   </xsl:element>
	   <xsl:text> &uir.right; </xsl:text>
	 </xsl:for-each>
	 <xsl:element name="br"/>
       </xsl:when>
       <xsl:otherwise>
	 <!--* 
	 <xsl:text>This code is used in all versions.</xsl:text>
	 <xsl:element name="br"/>
	 *-->
       </xsl:otherwise>
     </xsl:choose>
  </xsl:element>
 
   
   <!--* Then, callers. *-->  
   
  <xsl:element name="span">
    <xsl:attribute name="class">scrapinbound</xsl:attribute>

   <xsl:choose>
    <xsl:when test="//scrap/ptr[@target=$calledscrap] or
	     //scrap/ref[@target=$calledscrap] ">
     <xsl:text>This code is used in </xsl:text>
     <xsl:for-each select="//scrap/ptr[@target=$calledscrap] |
		   //scrap/ref[@target=$calledscrap]">
      <xsl:if test="not(preceding-sibling::ptr[@target=$calledscrap] |
		   preceding-sibling::ref[@target=$calledscrap])">
       <xsl:text>&uir.left; </xsl:text>
       <xsl:element name="a">
	<xsl:attribute name="href">
	 <xsl:text>#</xsl:text>
	 <xsl:choose>
	  <xsl:when test="../@id and $retain-ids = 'true'"><xsl:value-of select="../@id"/></xsl:when>
	  <xsl:otherwise><xsl:value-of select="generate-id(..)"/></xsl:otherwise>
	 </xsl:choose>
	</xsl:attribute>
	<xsl:apply-templates select=".." mode="getscrapref"/>
       </xsl:element>
       <xsl:text> &uir.right; </xsl:text>
      </xsl:if>
     </xsl:for-each>
     <xsl:element name="br"/>
    </xsl:when>
    <xsl:when test="./@corresp">
      <xsl:text>This code is a variant of </xsl:text>
      
      <xsl:for-each select="//scrap[@id=current()/@corresp]">
	<xsl:text>&uir.left; </xsl:text>
	<xsl:element name="a">
	  <xsl:attribute name="href">
	    <xsl:text>#</xsl:text>
	    <xsl:choose>
	      <xsl:when test="@id and $retain-ids = 'true'">
		<xsl:value-of select="@id"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="generate-id(.)"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:apply-templates select="." mode="getscrapref"/>
	</xsl:element>
	<xsl:text> &uir.right; </xsl:text>	
      </xsl:for-each>
    </xsl:when>    
    <xsl:when test="./@prev">
      <!--* do nothing *-->
    </xsl:when>
    <xsl:when test="./@file">
      <!--* do more nothing *-->
    </xsl:when>
    <xsl:otherwise>
     <xsl:text>This code is not used elsewhere.</xsl:text>
     <xsl:element name="br"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:element> 
 </xsl:template>

 <!--* Elements inside scraps *-->
 <xsl:template match="scrap/ptr | scrap/ref">
  <!--* If you ever again have a desire to make SWeb work neatly 
      * in IE, with its mistreatment of whitespace nodes, 
      * this template will have to change. *-->
  <xsl:element name="span">
   <xsl:attribute name="class">scrapref</xsl:attribute>
   <xsl:text>&sr.left; </xsl:text>
   <xsl:element name="em">
    <xsl:attribute name="class">scrapptr</xsl:attribute>
    <xsl:element name="a">
     <xsl:attribute name="href">
      <xsl:text>#</xsl:text>
      <xsl:choose>
       <xsl:when test="$retain-ids = 'true'"><xsl:value-of select="@target"/></xsl:when>
       <xsl:otherwise><xsl:value-of select="generate-id(id(@target))"/></xsl:otherwise>
      </xsl:choose>     
     </xsl:attribute>
     <xsl:choose>
      <xsl:when test="id(@target)">
       <xsl:apply-templates select="id(@target)" mode="getscrapref"/>
      </xsl:when>
      <xsl:otherwise>
       <xsl:value-of select="."/>
       <xsl:text> !! BAD REFERENCE! No scrap called </xsl:text>
       <xsl:value-of select="@target"/>
       <xsl:text>!</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:element>
   </xsl:element>
   <xsl:text> &sr.right;</xsl:text>
  </xsl:element>
  <!--* <xsl:text>}&#xA;</xsl:text> *-->
 </xsl:template>

 <xsl:template match="scrap/lb">
  <xsl:element name="br"/>
 </xsl:template>

 <xsl:template match="scrap/text()">
  <!--* If you ever again have a desire to make SWeb work neatly 
      * in IE, with its mistreatment of whitespace nodes, 
      * this template will have to change. *-->
  <!--* <xsl:value-of select="translate(.,' ','&#xA0;')"/> *-->
  <!--* kill a leading newline and a trailing newline, but no others. *-->
  <xsl:variable name="len-minus-1" select="string-length(.) - 1"/>
  <xsl:choose>
   <!--* if this is the only child and both begins and ends with xA,
       * then trim both *-->
   <xsl:when test="position() = 1 and starts-with(.,'&#xA;')
                   and position() = last() and substring(.,$len-minus-1) = '&#xA;'">
    <xsl:value-of select="substring(.,2,$len-minus-1)"/>
   </xsl:when>
   <!--* Trim two leading xA from first child. *-->
   <!--* Tangle strips only one, so starting a scrap with a blank line
       * leads tangle to put a newline before the scrap.  This makes
       * the tangled output neater, but we don't want the extra 
       * blank line in the formatted display, so we strip two here.
       *-->
   <xsl:when test="position() = 1 and starts-with(.,'&#xA;&#xA;')">
    <xsl:value-of select="substring(.,3)"/>
   </xsl:when>
   <!--* Trim leading xA from first child *-->
   <xsl:when test="position() = 1 and starts-with(.,'&#xA;')">
    <xsl:value-of select="substring(.,2)"/>
   </xsl:when>
   <!--* Trim trailing xA from last child *-->
   <xsl:when test="position() = last() and substring(.,$len-minus-1) = '&#xA;'">
    <xsl:value-of select="substring(.,1,$len-minus-1)"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="."/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!--* Index generation *-->

 <xsl:template match="divGen[@type='index-filenames']">
   <xsl:if test="$msglvl >= $verbose">
     <xsl:message>Doing index of filenames ...</xsl:message>
   </xsl:if>
   
   <xsl:variable name="depth" select="count(ancestor::div) + 1"/>
   <xsl:element name="div">   
     <xsl:element name="h{$depth}">
       <xsl:text>Index of file names</xsl:text>
     </xsl:element>
     <xsl:choose>
       <xsl:when test="//scrap[@file]">
	 <xsl:element name="ul">
	   <xsl:for-each select="//scrap/@file">
	     <xsl:sort/>
	     <xsl:variable name="filename" select="string(.)"/>
	     <xsl:if test="not(../preceding::scrap[@file = $filename])">
	       <xsl:element name="li">
		 <xsl:value-of select="."/>
		 <xsl:call-template name="get-scraps-by-file">
		   <xsl:with-param name="fn"><xsl:value-of select="."/></xsl:with-param>
		 </xsl:call-template>
	       </xsl:element>
	     </xsl:if>
	   </xsl:for-each>
	 </xsl:element>
       </xsl:when>
       <xsl:otherwise>
	 <xsl:element name="p">[No files are generated by this web.]</xsl:element>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:element>
   
   <xsl:if test="$msglvl >= $verbose">
     <xsl:message>... done with index of filenames.</xsl:message>
   </xsl:if>
   
 </xsl:template>

 <xsl:template name="get-scraps-by-file">
  <xsl:param name="fn">this is not a file name</xsl:param>
  <xsl:text>: defined in </xsl:text>
  <xsl:for-each select="//scrap[@file=$fn]">
   <xsl:if test="position() > 1"><xsl:text>, </xsl:text></xsl:if>
   <xsl:text>&fr.left; </xsl:text>
   <xsl:element name="a">
    <xsl:call-template name="make-href-to-current"/>
    <xsl:apply-templates select="." mode="getscrapnumref"/>
   </xsl:element>
   <xsl:text> &fr.right; </xsl:text>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="divGen[@type='index-scrapnames']">
   <xsl:if test="$msglvl >= $verbose">
     <xsl:message>Doing index of scrap names ...</xsl:message>
   </xsl:if>   
   
   <xsl:variable name="depth" select="count(ancestor::div) + 1"/>
   <xsl:element name="div">   
     <xsl:element name="h{$depth}">
       <xsl:text>Index of scrap names</xsl:text>
     </xsl:element>
     
     <xsl:choose>
       <xsl:when test="//scrap">
	 <xsl:element name="ul">
	   <xsl:for-each select="//scrap">
	     <xsl:sort select="@name"/>
	     <xsl:element name="li">
	       <xsl:element name="a">
		 <xsl:call-template name="make-href-to-current"/>
		 <xsl:call-template name="getscrapref"/>
	       </xsl:element>
	     </xsl:element>
	   </xsl:for-each>
	 </xsl:element>
       </xsl:when>
       <xsl:otherwise>
	 <xsl:element name="p">[No scraps are present in this web.]</xsl:element>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:element>
   <xsl:if test="$msglvl >= $verbose">
     <xsl:message>... done with index of scrap names.</xsl:message>
   </xsl:if>
 </xsl:template>

 <xsl:template match="divGen[@type='revision-history']">
   <xsl:variable name="depth" select="count(ancestor::div) + 1"/>
   <xsl:element name="div">   
     <xsl:element name="h{$depth}">
       <xsl:text>Index of scrap names</xsl:text>
     </xsl:element>
     
     <xsl:choose>
       <xsl:when test="/TEI.2/teiHeader/revisionDesc/list">
	 <xsl:apply-templates select="/TEI.2/teiHeader/revisionDesc/list"/>
       </xsl:when>
       <xsl:otherwise>
	 <xsl:element name="p">[There is no revision history in the header
	 of this document.]</xsl:element>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:element>
 </xsl:template>


 <!--* Phrase- and chunk-level elements for litprog (Poor Folks' Docbook?) *-->

 <xsl:template match="att">
  <xsl:element name="em">
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>
 <xsl:template match="tag">
  <xsl:element name="tt">
   <xsl:text>&lt;</xsl:text>
   <xsl:apply-templates/>
   <xsl:text>&gt;</xsl:text>
  </xsl:element>
 </xsl:template>
 <xsl:template match="code[@lang='sgml']">
  <xsl:element name="tt">
   <xsl:text>&lt;</xsl:text>
   <xsl:apply-templates/>
   <xsl:text>&gt;</xsl:text>
  </xsl:element>
 </xsl:template>

 <xsl:template match="list[contains(@type,'desclist')]" mode="oldstyle">
  <xsl:element name="dl">
   <xsl:attribute name="class">desclist</xsl:attribute>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>
 <xsl:template match="list[contains(@type,'desclist')]/label" mode="oldstyle">
  <xsl:element name="dt">
   <xsl:element name="span">
    <!--* span seems to protect against a Webkit bug in display: run-in. *-->
    <xsl:apply-templates/>
   </xsl:element>
  </xsl:element>
 </xsl:template>
 <xsl:template match="list[contains(@type,'desclist')]/item" mode="oldstyle">
  <xsl:element name="dd">
  <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>

 <xsl:template match="list[contains(@type,'desclist')]">
  <xsl:element name="ul">
   <xsl:attribute name="class">desclist</xsl:attribute>
   <xsl:apply-templates/>
  </xsl:element>
 </xsl:template>
 <xsl:template match="list[contains(@type,'desclist')]/label">
  <xsl:element name="li">
   <xsl:apply-templates/>
   <xsl:text> </xsl:text>
   <xsl:apply-templates mode="desclist-item" select="following-sibling::*[1]"/>
  </xsl:element>
 </xsl:template>
 <xsl:template match="list[contains(@type,'desclist')]/item"/>
 <xsl:template match="list[contains(@type,'desclist')]/item" mode="desclist-item">
  <xsl:apply-templates/>
 </xsl:template>


 <xsl:template match="ptr[@type='scrapnum']" name="scrapnumref">

  <xsl:element name="a">
   <xsl:attribute name="name">ref-to-<xsl:value-of select="@target"/></xsl:attribute>
   <xsl:attribute name="href">#<xsl:value-of select="@target"/></xsl:attribute>
   <xsl:apply-templates mode="getscrapnum" select="id(@target)"/>
  </xsl:element>
 </xsl:template>

 <xsl:template match="ptr" name="implicit-scrapnumref">
  <xsl:choose>
   <xsl:when test="count(@type)=0 and id(@target)/self::scrap">
    <xsl:call-template name="scrapnumref"/>
   </xsl:when>
   <xsl:otherwise><xsl:apply-imports/></xsl:otherwise>
  </xsl:choose>
 </xsl:template>

</xsl:stylesheet>
<!-- Keep this comment at the end of the file
Local variables:
mode: xml
sgml-default-dtd-file:(concat sgmlvol "/Library/SGML/Public/Emacs/xslt.ced")
sgml-omittag:t
sgml-shorttag:t
sgml-indent-data:t
sgml-indent-step:1
End:
-->
