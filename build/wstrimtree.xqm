module namespace ws = 'http://blackmesatech.com/2019/iXML/wstrimtree';

(: Whitespace trimming for trees.  :)

(: Revisions:
   2019-04-29 : CMSMcQ : made file
   :)

(: ................................................................
   trimtree($n, lnPreserve, lnStrip):  return copy of node n, 
   deep-equal except for removing whitespace-only nodes which are
   children of elements matched by (anything in) lntStrip and
   not matched by anything in lntPreserve.

   The arguments are like xsl:preserve-space and xsl:strip-space 
   but weaker:  
   1 we demand EQNames or '*', we do not support QNames or prefix:*.
   2 either lnPreserve or lnStrip must be '*'
   3 the other must be a list of EQNames.
   :)
declare function ws:trimtree(
  $n as node(),
  $lnPreserve as xs:string*,
  $lnStrip as xs:string*)
  as node()? {
    if ($n instance of document-node()) then
      document {
	for $c in $n/child::node()
	return ws:trimtree($c, $lnPreserve, $lnStrip)
      }
    else if ($n instance of element()) then
      element {name($n)} {
	$n/@*,
	for $c in $n/child::node()
	return ws:trimtree($c, $lnPreserve, $lnStrip)
      }
    else if ($n instance of comment()
      or $n instance of processing-instruction()
      or $n instance of attribute()) then
      $n
    else if (($n instance of text())
            and (normalize-space($n) ne '')) then
      $n
    else if (($n instance of text())
            and (normalize-space($n) = '')) then
      let $nParent := $n/parent::*
      let $nmParent := concat('{', namespace-uri($nParent), '}', 
                       local-name($nParent))
      return if (($lnStrip eq '*') and ($nmParent = $lnPreserve)) then
        $n
      else if ($nmParent = $lnStrip) then 
        ()
      else
        $n
    else $n       
};
