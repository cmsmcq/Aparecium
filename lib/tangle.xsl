<xsl:stylesheet version="3.0"
                xmlns:xsl =  "http://www.w3.org/1999/XSL/Transform"
		xmlns:xs  =  "http://www.w3.org/2001/XMLSchema"
		xmlns:sweb =  "http://cmsmcq.com/1993/sweb"
		>

  <!--* tangle.xsl:  process a literate program written in SWeb.
      * (To weave, just use swebtohtml.)
      *-->

  <!--* To do:
      * . Test.
      *-->

  <!--* Revisions:
      * 2021-12-25 : CMSMcQ : try to support simple version tagging.
      * 2021-10-03 : CMSMcQ : copy from ~/2000/11/wbs/msm, replace 
      * saxon:output with xsl:result-document.  Maybe that's all
      * we need.
      *-->
  
  <xsl:output method="text"
              encoding="utf8"
	      indent="no"
	      />

  <xsl:param name="version" as="xs:string" select=" '-unspecified-' "/>

  <xsl:variable name="fallbacks" as="xs:string*"
		select="sweb:fallbacks($version, //versionList)"/>

  <xsl:function name="sweb:fallbacks" as="xs:string+">
    <!--* lv:  a list of versions (specified version, its fallback, 
	* fallback of its fallback, etc., as long as the chain reaches.
	*-->
    <xsl:param name="lv" as="xs:string*"/>
    <!--* versionLists:  the versionList elements of the input *-->
    <xsl:param name="versionLists" as="element(versionList)*"/>

    <xsl:choose>
      <xsl:when test="empty($lv)">
	<!--* no versions?  no fallbacks *-->
	<xsl:sequence select="$lv"/>
      </xsl:when>
      <xsl:otherwise>
	<!--* find the fallback for the most recently added
	    * version. 
	    *-->
	<xsl:variable name="vCur" as="xs:string"
		      select="$lv[last()]"/>
	<xsl:variable name="vFallback" as="xs:string?"
		      select="($versionLists/version[@id =
			      $vCur])[1]/@fallback"/>
	<!--* If it had one, add it to the list and recur.
	    * Otherwise, we're done.
	    *-->
	<xsl:sequence select="if (exists($vFallback))
			      then sweb:fallbacks(
			        ($lv, $vFallback),
			        $versionLists)
			      else $lv"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

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

    <!--
    <xsl:message>Processing scrap <xsl:sequence
    select="."/></xsl:message>
    -->
    <xsl:if test="exists(@corresp) and empty(@version)">
      <xsl:message>
	<xsl:text>Warning: scrap </xsl:text>
	<xsl:value-of select="concat(@id, ' (', @n, ')')"/>
	<xsl:text> has @corresp set to "</xsl:text>
	<xsl:value-of select="@corresp"/>
	<xsl:text>" but no version attribute.</xsl:text>
	<xsl:text>&#xA;Meaning is undefined and unreliable.  Change it!</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="empty(@corresp) and exists(@version)">
      <xsl:message>
	<xsl:text>Warning: scrap </xsl:text>
	<xsl:value-of select="concat(@id, ' (', @n, ')')"/>
	<xsl:text> has @version set to "</xsl:text>
	<xsl:value-of select="@version"/>
	<xsl:text>" but no corresp attribute to say </xsl:text>
	<xsl:text>where it goes.</xsl:text>
	<xsl:text>&#xA;Meaning is undefined and unreliable.  Change it!</xsl:text>
      </xsl:message>
    </xsl:if>
    
    <!--* Before we do anything else, check to see
	* what the version labeling tells us about this
	* scrap.
	*-->
    <!--* $equivalents: other scraps that claim to be
	* equivalent to this one. *-->
    <xsl:variable name="equivalents" as="element(scrap)*"
		  select="(.,
			  if (empty($idCur))
			  then ()
			  else //scrap[@corresp = $idCur]
			  )"/>
    <!--* If there are multiple equivalent scraps,
	* we choose one based on version information
	*-->
    <xsl:variable
	name="chosen" as="element(scrap)"
	select="sweb:choose-scrap(
		$fallbacks,
		$equivalents)"/>
    
    <xsl:choose>
      <xsl:when test="not(. is $chosen)">
	<!--* In the version being processed, another
	    * scrap has replaced this one.  Use it
	    * instead.
	    *-->
	<xsl:apply-templates select="$chosen" mode="scrap"/>	
      </xsl:when>
      
      <xsl:when test="@version and not(@version = $fallbacks)">
	<xsl:message>
	  <xsl:text>Warning: scrap </xsl:text>
	  <xsl:value-of select="concat(@id, ' (', @n, ')')"/>
	  <xsl:text> is marked for version </xsl:text>
	  <xsl:value-of select="@version"/>
	  <xsl:text>,</xsl:text>
	  <xsl:text>&#xA;which is not in the version fallback list: </xsl:text>
	  <xsl:sequence select="$fallbacks"/>
	  <xsl:text>&#xA;Omitting from the tangled output.</xsl:text>
	  <xsl:text>&#xA;Version markup or tangle needs changing!</xsl:text>
	</xsl:message>
      </xsl:when>
      
      <xsl:otherwise>
	<xsl:apply-templates mode="scrap"/>
	
	<!--* if this scrap has an ID, we should now
	    * go and fetch all of its continuations,
	    * which are the elements which have the ID
	    * of this scrap as their @prev value.
	    *
	    * Note that when one scrap X replaces
	    * another scrap Y, X and its continuations
	    * replace Y *and all its continuations*.
	    *-->
	<xsl:if test="@id">
	  <!--
	      <xsl:message>Here we should be looking
	      for follow-ons, that is scraps with
	      prev="<xsl:value-of select="$idCur"
	      />".</xsl:message> -->
	  <xsl:apply-templates
	      mode="scrap" 
	      select="/descendant-or-self::scrap[@prev=$idCur]"/>
	</xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="sweb:choose-scrap" as="element(scrap)">
    <xsl:param name="fallbacks" as="xs:string*"/>
    <xsl:param name="le" as="element(scrap)+"/>

    <xsl:variable name="preferred-version" as="xs:string?"
		  select="$fallbacks[1]"/>
    
    <xsl:variable name="preferred-scrap" as="element(scrap)*"
		  select="if (exists($preferred-version))
			  then $le[@version = $preferred-version]
			  else ()"/>

    <xsl:variable name="unversioned-scrap" as="element(scrap)*"
		  select="$le[not(@version)]"/>
    
    <xsl:variable name="bogons" as="element(scrap)*"
		  select="$le[@corresp and not(@version)]"/>
    
    <xsl:choose>
      <!--* Error case:  this might not affect this particular
	  * call, but having scraps with @corresp and no
	  * @version is unacceptable.  Nip it in the bud.
	  *-->
      <xsl:when test="exists($bogons)">
	<xsl:message terminate="yes">
	  <xsl:text>&#xA;Fatal error:  equivalence class contains </xsl:text>
	  <xsl:text>scraps with corresp (</xsl:text>
	  <xsl:value-of select="string-join($bogons/@corresp, ', ')"/>
	  <xsl:text>) but no version: </xsl:text>
	  <xsl:value-of select="string-join(
				for $e in $bogons
				return concat($e/@id,
				' (', $e/@n, ') '),
				', '
				)"/>
	  <xsl:text>&#xA;Version markup or tangle needs changing!</xsl:text>
	  <xsl:text>&#xA;</xsl:text>
	</xsl:message>
      </xsl:when>
      
      <!--* Edge case:  there is only one scrap to choose.
	  * Choose it. *-->
      <xsl:when test="count($le) le 1">
	<xsl:sequence select="$le"/>
      </xsl:when>

      <!--* Have we found a preferred scrap? *-->
      <xsl:when test="count($preferred-scrap) gt 1">
	<xsl:message terminate="yes">
	  <xsl:text>&#xA;Fatal error: multiple equivalent </xsl:text>
	  <xsl:text>scraps with version</xsl:text>
	  <xsl:value-of select="$preferred-version"/>
	  <xsl:text>: </xsl:text>
	  <xsl:value-of select="string-join(
				for $e in $preferred-scrap
				return concat($e/@id,
				' (', $e/@n, ') '),
				', '
				)"/>
	  <xsl:text>&#xA;Version markup or tangle needs changing! &#xA;</xsl:text>
	</xsl:message>
      </xsl:when>

      <!--* Have we found a preferred scrap? *-->
      <xsl:when test="count($preferred-scrap) eq 1">
	<xsl:sequence select="$preferred-scrap"/>
      </xsl:when>

      <!--* We haven't found a preferred scrap, but are we out
	  * of options? *-->
      <xsl:when test="count($fallbacks) gt 0">
	<xsl:sequence select="sweb:choose-scrap(tail($fallbacks), $le)"/>
      </xsl:when>

      <!--* Fatal error:  we fell back to unmarked scraps 
	  * and found more than one. *-->
      <xsl:when test="empty($fallbacks) and count($unversioned-scrap)
		      gt 1">
	<xsl:message terminate="yes">
	  <xsl:text>&#xA;Fatal error: multiple equivalent </xsl:text>
	  <xsl:text>unversioned scraps: </xsl:text>
	  <xsl:value-of select="for $e in $unversioned-scrap
				return concat($e/@id, ' (', $e/@n, ') ')"/>
	  <xsl:text>&#xA;Version markup or tangle needs changing!&#xA;</xsl:text>
	</xsl:message>
      </xsl:when>
      <!--* Fatal error:  we fell back to unmarked scraps 
	  * and found none. *-->
      <xsl:when test="empty($fallbacks) and count($unversioned-scrap)
		      = 0">
	<xsl:message terminate="yes">
	  <xsl:text>&#xA;Fatal error: found no equivalent </xsl:text>
	  <xsl:text>unversioned scraps when I needed one! </xsl:text>
	  <xsl:text>&#xA;Version markup or tangle needs changing! &#xA;</xsl:text>
	</xsl:message>
      </xsl:when>
      <!--* Goldilocks fallback: one unmarked scrap when we
	  * needed one. *-->
      <xsl:when test="empty($fallbacks) and count($unversioned-scrap)
		      = 1">
	<xsl:sequence select="$unversioned-scrap"/>
      </xsl:when>

      <xsl:otherwise>
	<xsl:message terminate="yes">
	  <xsl:text>&#xA;Fatal error: unforeseen case in choose-scrap()!</xsl:text>
	  <xsl:text>&#xA;Tangle needs changing! &#xA;</xsl:text>
	</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
