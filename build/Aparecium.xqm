module namespace aparecium =
"http://blackmesatech.com/2019/iXML/Aparecium";

(: Aparecium:  a library to make invisible XML visible.

    ... Hermione was pulling her wand out of her bag.
    "It might be invisible ink!" she whispered.
    She tapped the diary three times and said, "Aparecium!"
      
                           - J. K. Rowling, Harry Potter 
                           and the Chamber of Secrets

:)

import module namespace earley
   = "http://blackmesatech.com/2019/iXML/Earley-parser"
  at "Earley-parser.xqm";
import module namespace gluschkov
   = "http://blackmesatech.com/2019/iXML/Gluschkov"
  at "Gluschkov.xqm";
  
(: Quick hack for testing ... :)
import module namespace ws
   = "http://blackmesatech.com/2019/iXML/wstrimtree"
   at "wstrimtree.xqm";

(: ******************************************************
   * Main interfaces (and the simplest) 
   ******************************************************
   :)
  
(: ......................................................
   doc($InputURI)
   ......................................................
   Given the URI of the input, fetch the ixml grammar 
   describing it and return the XML representation of 
   the resource.
:)

(: TO BE IMPLEMENTED: use html fetch to get both HTTP
header and payload.  If MIME type is ixml, fetch grammar
and call parse-string.  Otherwise, if XML and 200 return
payload, otherwise return header and payload.

declare function aparecium:doc(
  $uriI as xs:string
) as element() {
  let $sI := unparsed-text($uriI),
      $sG := unparsed-text($uriG)
  return aparecium:parse-string($sI, $sG)
};
:)

(: ......................................................
   parse-resource($Input, $Grammar)
   ......................................................
   Given URIs for the input and an ixml grammar 
   describing it, returns the XML representation of 
   the resource.
:)

declare function aparecium:parse-resource(
  $uriI as xs:string,
  $uriG as xs:string
) as element() {
  let $sI := unparsed-text($uriI),
      $sG := unparsed-text($uriG)
  return aparecium:parse-string($sI, $sG)
};
   
(: ......................................................
   parse-string($Input, $Grammar)
   ......................................................
   Given strings with the input and an ixml grammar
   describing it, returns the XML representation of the
   resource.
:)

declare function aparecium:parse-string(
  $sI as xs:string,
  $sG as xs:string
) as element() {
  let $cG := aparecium:compile-grammar-from-string($sG)
  return 
    aparecium:parse-string-with-compiled-grammar($sI, $cG)
};
   
(: ......................................................
   parse-string-with-compiled-grammar($Input, $Grammar)
   ......................................................
:)
declare function aparecium:parse-string-with-compiled-grammar(
  $sI as xs:string,
  $cG as element(ixml)
) as element() {
  (: let $trace := trace((),'
parse-string-'
                   || ' with-compiled-grammar()
') :)
  let $result := prof:time(
                 earley:all-trees($sI, $cG) 
                 , '0 Outer call: ')

  return if (count($result) eq 1)
         then $result
         else <forest 
              xmlns:ixml="http://invisiblexml.org/NS"
	      >{$result}</forest>
};

(: ******************************************************
   * Secondary interfaces (a bit more specialized) 
   ******************************************************
   :)
   
(: ......................................................
   parse-grammar-from-uri($ixmlGrammar)
   ......................................................
   Given the URI of an ixml grammar, returns the XML 
   representation of the grammar.  
   
   Retrieves the grammar and parses it by calling
   parse-grammar-from-string().
:)
declare function aparecium:parse-grammar-from-uri(
  $uriG as xs:string
) as element() {
  let $sG := unparsed-text($uriG)
  return aparecium:parse-grammar-from-string($sG)
};
   
(: ......................................................
   parse-grammar-from-string($ixmlGrammar)
   ......................................................
   Given the string form of an ixml grammar, returns the
   XML representation of the grammar.
   
   Retrieves the grammar and parses it by calling
   parse-string-with-compiled-grammar with the ixml
   grammar for ixml grammars.
:)

declare function aparecium:parse-grammar-from-string(
  $G as xs:string
) as element(ixml) {
  (: CGIG:  compiled grammar for ixml grammars :)
  let $CGIG := doc($aparecium:ixml.gl.xml)/ixml,
      (: PG: parsed grammar :)
      $PG := aparecium:parse-string-with-compiled-grammar($G,$CGIG)
  return if ($PG/self::forest) 
      then trace($PG/ixml,
                 'Warning:  submitted grammar was ambiguous.') 
      else if ($PG/self::Goal) 
      then $PG/ixml 
      else if ($PG/self::ixml) 
      then $PG
      else <ixml>
        <!--* Something is very wrong here *-->
        { $PG }
      </ixml>
};   
      
(: ......................................................
   compile-grammar-from-uri($ixmlGrammar)
   ......................................................
   Given the URI of an ixml grammar, returns the
   compiled XML representation of the grammar.
:)  

declare function aparecium:compile-grammar-from-uri(
  $uriG as xs:string
) as element() {
  let $xmlG := aparecium:parse-grammar-from-uri($uriG)
  return gluschkov:ME($xmlG)
};
      
(: ......................................................
   compile-grammar-from-string($ixmlGrammar)
   ......................................................
   Given the URI of an ixml grammar, returns the XML 
   representation of the grammar.  
:)  
 
declare function aparecium:compile-grammar-from-string(
  $sG as xs:string
) as element() {
  let $xmlG := aparecium:parse-grammar-from-string($sG)
  return gluschkov:ME($xmlG)
};

(: ......................................................
   compile-grammar-from-xml($ixmlGrammar)
   ......................................................
   Given the XML representation of an ixml grammar,
   returns an annotated representation of the grammar
   that makes it usable by the Earley parser.
:)   

declare function aparecium:compile-grammar-from-xml(
  $xmlG as element(ixml)
) as element(ixml) {
  gluschkov:ME($xmlG)
};



(: ******************************************************
   * Tertiary interfaces (of interest only for maintainer) 
   ******************************************************
   :)

(: This is bootstrapping code (for building the Gluschkov
   automaton of the ixml grammar for ixml grammars.  It 
   should be run once whenever the grammar changes -- that 
   is, almost never.  But for now, it's here. 
   :)
  
(: Note that these don't save the result to disk; that's
   not automated yet.
   :)

   (: reparse-ixml-grammar(): produce fresh XML version :)
   
   (: The path starting from Goal on all these is a 
      temporary hack. :)
   
declare function aparecium:reparse-ixml-grammar(
) as element(ixml) {
  aparecium:parse-grammar-from-uri(
      $aparecium:ixml.ixml
  )/Goal/ixml
};
 
(: recompile-ixml-grammar(): produce fresh annotated XML
:)
declare function aparecium:recompile-ixml-grammar(
) as element(ixml) {
  aparecium:compile-grammar-from-uri(
      $aparecium:ixml.ixml
  )/Goal/ixml
};

(: ******************************************************
   * Variables (of interest only for maintainer) 
   ******************************************************
   :)
declare variable $aparecium:libloc as xs:string
  := '../lib';
declare variable $aparecium:ixml.ixml as xs:string
  := $aparecium:libloc || '/ixml.2022-01-25.ixml';

declare variable $aparecium:ixml.xml as xs:string
  := $aparecium:libloc || '/ixml.2022-01-25.ixml.xml';
  
declare variable $aparecium:ixml.gl.xml as xs:string
  := $aparecium:libloc || '/ixml.2022-01-25.ixml.compiled.xml';  

