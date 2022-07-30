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
import module namespace d2x 
   = 'http://blackmesatech.com/2019/iXML/d2x'
  at "d2x.xqm";

declare namespace map = 
"http://www.w3.org/2005/xpath-functions/map";
  
(: Quick hack for testing ... :)
import module namespace ws
   = "http://blackmesatech.com/2019/iXML/wstrimtree"
   at "wstrimtree.xqm";



(: ******************************************************
   * Main interfaces (and the simplest) 
   ******************************************************
   :)  
(: ......................................................
   parse-resource($Input, $Grammar)
   ......................................................
:)
declare function aparecium:parse-resource(
  $uriI as xs:string,
  $uriG as xs:string
) as element() {
  aparecium:parse-resource($uriI, $uriG, $aparecium:options)
};

declare function aparecium:parse-resource(
  $uriI as xs:string,
  $uriG as xs:string,
  $options as map(*)
) as element() {
  let $sI := if (unparsed-text-available($uriI))
             then unparsed-text($uriI)
             else (),
      $sG := if (unparsed-text-available($uriG))
             then unparsed-text($uriG)
             else ()
  return if (exists($sI) and exists($sG))
         then aparecium:parse-string($sI, $sG, $options)
         else          if (exists($sI))
         then element aparecium:error {
              attribute id { "ap:tbd01" },
              "Grammar (" || $uriG || ") not found."
         }
         else if (exists($sG))
         then element aparecium:error {
              attribute id { "ap:tbd02" },
              "Input string (" || $uriI || ") not found."
         }
         else element aparecium:error {
              attribute id { "ap:tbd03" },
              "Input string (" || $uriI || ") not found.",
              "Grammar (" || $uriG || ") not found.",
              "You're breaking my heart here."
         }

};

(: ......................................................
   parse-string($Input, $Grammar)
   ......................................................
:)

declare function aparecium:parse-string(
  $sI as xs:string,
  $sG as xs:string
) as element() {
  aparecium:parse-string($sI, $sG, $aparecium:options)
};

declare function aparecium:parse-string(
  $sI as xs:string,
  $sG as xs:string,
  $options as map(*)
) as element() {
  let $cG := (:stat ...prof:time( ... tats:)
             aparecium:compile-grammar-from-string($sG, $options)
             (:stat ..., 
             'parse-string: compiling grammar from string:') 
             ... tats:)
             
  return 
    if ($cG/self::aparecium:error)
    then element aparecium:error {
      attribute id { "ap:tbd04" },
      "parse-string():  Error compiling grammar.",
      $cG      
    }
    else (:stat ...prof:time( ... tats:)
         aparecium:parse-string-with-compiled-grammar(
             $sI, $cG, $options
         )
         (:stat ..., 'parse-string:  parsing input string:') ... tats:)
};

(: ......................................................
   parse-string-with-compiled-grammar($Input, $Grammar)
   ......................................................
:)
declare function aparecium:parse-string-with-compiled-grammar(
  $sI as xs:string,
  $cG as element(ixml)
) as element() {
  aparecium:parse-string-with-compiled-grammar(
      $sI, $cG, $aparecium:options
  )
};

declare function aparecium:parse-string-with-compiled-grammar(
  $sI as xs:string,
  $cG as element(ixml),
  $options0 as map(*)
) as element() {
  let $options := map:merge(($options0, $aparecium:options))

  let $cg-ok := (:stat ...prof:time( ... tats:)
                aparecium:grammar-ok($cG, $options)
                (:stat ..., 'pswcg() calling grammar-ok():') ... tats:)

  let $result := if ($cg-ok/self::ixml) 
                 then (:stat ...prof:time( ... tats:)
                     earley:parse($sI, $cG, $options) 
                     (:stat ...
                     , '0 Outer call to earley:parse(): ')
                      ... tats:)
                 else element aparecium:error {
                   attribute id { "ap:tbd05" },
                   "Compiled grammar flawed:",
                   $cg-ok
                 }
		 
  return if (count($result) eq 1)
         then $result
         else <forest 
              xmlns:ixml="http://invisiblexml.org/NS"
	      >{$result}</forest>
};

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


(: ******************************************************
   * Secondary interfaces (a bit more specialized) 
   ******************************************************
   :)

(: ......................................................
   parse-grammar-from-uri($ixmlGrammar)
   ......................................................
:)
declare function aparecium:parse-grammar-from-uri(
  $uriG as xs:string
) as element() {
  aparecium:parse-grammar-from-uri(
      $uriG,
      $aparecium:options
  )
};
declare function aparecium:parse-grammar-from-uri(
  $uriG as xs:string,
  $options as map(*)
) as element() {
  let $sG := if (unparsed-text-available($uriG))
             then unparsed-text($uriG)
             else ()
  return if (exists($sG)) 
         then aparecium:parse-grammar-from-string(
                  $sG, 
                  $options
              )
         else element aparecium:error {
           attribute id { "ap:tbd14" },
           "Grammar (" || $uriG || ") not found."
         }
};


(: ......................................................
   parse-grammar-from-string($ixmlGrammar)
   ......................................................
:)

declare function aparecium:parse-grammar-from-string(
  $G as xs:string
) as element() {
  aparecium:parse-grammar-from-string(
      $G,
      $aparecium:options
  )
};

declare function aparecium:parse-grammar-from-string(
  $G as xs:string,
  $options as map(*)
) as element() {
  (: CGIG:  compiled grammar for ixml grammars :)
  let $CGIG := doc($aparecium:ixml.gl.xml)/ixml,
      (: PG: parsed grammar :)
      $PG0 := aparecium:parse-string-with-compiled-grammar(
                  $G,
                  $CGIG,
                  $options
              ),
      $PG := (:stat ...prof:time( ... tats:)
             aparecium:grammar-ok($PG0, $options)
             (:stat ..., 'pgfs() calling grammar-ok():') ... tats:)
  return $PG
};


(: ......................................................
   compile-grammar-from-uri($ixmlGrammar)
   ......................................................
:)  

declare function aparecium:compile-grammar-from-uri(
  $uriG as xs:string
) as element() {
  aparecium:compile-grammar-from-uri(
    $uriG,
    $aparecium:options
  )
};

declare function aparecium:compile-grammar-from-uri(
  $uriG as xs:string,
  $options as map(*)
) as element() {
  let $xmlG := aparecium:parse-grammar-from-uri($uriG, $options)
  return gluschkov:ME($xmlG, $options)
};


(: ......................................................
   compile-grammar-from-string($ixmlGrammar)
   ......................................................
:)  
 
declare function aparecium:compile-grammar-from-string(
  $sG as xs:string
) as element() {
  aparecium:compile-grammar-from-string(
    $sG, 
    $aparecium:options
  )
};

declare function aparecium:compile-grammar-from-string(
  $sG as xs:string,
  $options as map(*)
) as element() {
  let $xmlG := aparecium:parse-grammar-from-string($sG)
  return gluschkov:ME($xmlG, $options)
};


(: ......................................................
   compile-grammar-from-xml($ixmlGrammar)
   ......................................................
   Given the XML representation of an ixml grammar,
   returns an annotated representation of the grammar
   that makes it usable by the Earley parser.
:)   

declare function aparecium:compile-grammar-from-xml(
  $xmlG as element()
) as element(ixml) {
  aparecium:compile-grammar-from-xml(
    $xmlG,
    $aparecium:options
  )
};

declare function aparecium:compile-grammar-from-xml(
  $xmlG as element(),
  $options as map(*)
) as element(ixml) {
  let $G := (:stat ...prof:time( ... tats:)
            aparecium:grammar-ok($xmlG, $options)
            (:stat ..., 'cgfx() calling grammar-ok():') ... tats:)
  return if ($G/self::ixml)
         then gluschkov:ME($xmlG, $options)
         else element aparecium:error {
           attribute id { "ap:tbd15" },
           "compile-grammar-from-xml(): ",
           "Unable to compile grammar: ",
	   "grammar not ok."
         }
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

(: grammar-ok(): check grammar 
:)
declare function aparecium:grammar-ok(
  $G as element(),
  $options as map(*)
) as element() {
  if ($G/self::ixml)
  then 
  let $dummy := () (: trace($G/rule[1]/@name/string(),
                'grammar-ok() called on grammar for: ') :)
    let $lee-struc := (
      let $le0 := $G/*
          [not(self::prolog or self::rule or self::comment or self::pragma)]
      for $e in $le0 
      return element aparecium:error {
        attribute id { "ap:tbd08" },
        "Unexpected " || $e/name() 
        || " element as child of ixml."
      },

      let $le0 := $G/rule/*
          [not(self::alt or self::comment or self::pragma)]
      for $e in $le0 
      return element aparecium:error {
        attribute id { "ap:tbd09" },
        "Unexpected " || $e/name() 
        || " element as child of rule."
      }


  )
      

    let $lee-comp := ()

    let $lee-names := (
      for $r in $G/rule
                [not(@name castable as xs:NCName)]
      let $nt := $r/@name/string(),
          $mark := string($r/@mark),
          $references := $G//nonterminal[@name eq $nt],
          $rmarks := distinct-values(
	      for $ref in $references
              return string($ref/@mark)
          ),
          $is-hidden := (( ($mark = ('^', '@', ''))
               and ($rmarks = ('^', '@', '')) )
            or ( ($mark eq '-')
               and ($rmarks = ('^', '@')) ))
      return if ($is-hidden)
          then element aparecium:error {
               attribute id { "ap:tbd22" },
               $nt || " is not allowed as an XML name."
               || " Aparecium does not support nonterminals"
               || " which are not XML names, even when hidden."
          }
          else element aparecium:error {
               attribute id { "ap:tbd11" },
               $nt || " is not allowed as an XML name."
               || " It must be marked as hidden."
          }
  ) 

    let $lee-uniqdef := (
      for $r in $G/rule
      let $nt := string($r/@name)
      group by $nt
      return if (count($r) gt 1)
      then (
        trace((), 
           "Symbol " || $nt 
           || " defined " || count($r) || "×: "),
        element aparecium:error {
        attribute id { "ap:tbd12" },
        $nt || " is defined " ||
        (if (count($r) eq 2)
        then "twice"
        else count($r) || " times")
        || "."
      })
      else ()
  )

    let $lee-charclass := (
      for $cc in ($G//class/@code,
                  $G//member/@code)
      let $nt := string($cc/ancestor::rule/@name)
      where not(matches($cc,
                '^(L[ultmo]?'
                || '|M[nce]?'
                || '|N[dlo]?'
                || '|P[cdseifo]?'
                || '|Z[slp]?'
                || '|S[mcko]?'
                || '|C[cfon]?)$'))
      return element aparecium:error {
        attribute id { "ap:tbd16" },
        "Character class", string($cc), 
        "in the definition of", $nt, 
        "is not known."
      }
  )

    let $lee-hex := (
      for $hexref in ($G//literal/@hex,
                  $G//member/@hex,
                  $G//member/(@from | @to)
                      [starts-with(., '#') 
                      and string-length(.) gt 1]
		  )
      let $nt := string($hexref/ancestor::rule/@name),
          $hexstring := if (starts-with($hexref, '#'))
                        then substring($hexref, 2)
                        else string($hexref),
          $int := try { 
                    d2x:x2d($hexstring) 
                  } catch err:FOAR0002 {  
                    -1 (: out of range, assume too big :)
                  } catch * {  
                    -2 (: who knows?  Assume bad hex :)
                  }
      return         if ($int eq -1)
        then element aparecium:error {
             attribute id { "ap:tbd18" },
             attribute code { "ixml:S07" },
             "Hex value ", $hexstring, 
             "in the definition of", $nt, 
             "is too large. Entirely too large."
	} 
        else if ($int eq -2)
        then element aparecium:error {
             attribute id { "ap:tbd19" },
             attribute code { "ixml:S08" },
             "Hex value ", $hexstring, 
             "in the definition of", $nt, 
             "cannot be converted to an integer."
        } 
        else if ($int lt 0 or $int gt 1114111)
        then element aparecium:error {
             attribute id { "ap:tbd26" },
             attribute code { "ixml:S07" },
             "Hex value ", $hexstring, 
             "( = ", string($int), ")", 
             "in the definition of", $nt,
             "lies outside the Unicode range",
	     "(0 to 1114111)."
        } 
        else if ($int ge 55296 and $int le 57343)
              (: xD800 to xDFFFF :)
        then element aparecium:error {
             attribute id { "ap:tbd27" },
             attribute code { "ixml:S08" },
             "Hex value ", $hexstring, 
             "( = ", string($int), ")", 
             "in the definition of", $nt,
             "is not a Unicode character",
	     "(it is a surrogate code point)."
        } 
        else if (ends-with(upper-case($hexstring), 'FFFF')
             or  ends-with(upper-case($hexstring), 'FFFE'))
        then element aparecium:error {
             attribute id { "ap:tbd28" },
             attribute code { "ixml:S08" },
             "Hex value ", $hexstring, 
             "( = ", string($int), ")", 
             "in the definition of", $nt,
             "is not a Unicode character",
	     "(it is a non-character)."
        }
        else ()
  )


    let $lee-ranges := (
      for $ref in $G//member[@from and @to]
      let $nt := string($ref/ancestor::rule[1]/@name),
          $cp-from := if (string-length($ref/@from) eq 1)
                      then string-to-codepoints($ref/@from)
	              else d2x:x2d(substring($ref/@from, 2)),
          $cp-to := if (string-length($ref/@to) eq 1)
                    then string-to-codepoints($ref/@to)
                    else d2x:x2d(substring($ref/@to, 2))
      return if ($cp-to lt $cp-from)
      then element aparecium:error {
           attribute id { "ap:tbd29" },
           attribute code { "ixml:S09" },
           "Range", 
           $ref/@from/string(), '-', $ref/@to/string(),
           '(=', $cp-from, '-', $cp-to, ")",
           "in the definition of",
           $nt || " is not a good range.",
           "(The end of the range must",
           "be higher than the beginning.)" 
      }
      else ()
  )

    let $lee-alldef := (
      for $ref in $G//nonterminal
      let $nt := string($ref/@name)
      group by $nt
      return if (empty($G/rule[@name eq $nt]))
      then element aparecium:error {
        attribute id { "ap:tbd13" },
        attribute code { "ixml:S02" },
        $nt || " is referred to but not defined." 
      }
      else ()
  )

    let $lee-reachable := ()

    let $lee-productive := ()

  let $lee-all := ($lee-struc, $lee-comp,
                   $lee-names,  
                   $lee-uniqdef, $lee-charclass,
                   $lee-hex, $lee-ranges,
                   $lee-alldef, 
                   $lee-reachable, $lee-productive)
  return if (empty($lee-all/self::aparecium:error))
  then $G
  else (: not(empty($lee-all/self::ap:error)) :)
    element aparecium:error {
      attribute id { "ap:tbd06" },
      element p { "Errors found in grammar." },
      $lee-all,
      $G
  }
  else (: not($G/self::ixml) :) 
    element aparecium:error {
      attribute id { "ap:tbd07" },
      element p { "This is not a grammar." },
      $G
  }
};


(: ******************************************************
   * Variables (of interest only for maintainer) 
   ******************************************************
   :)
declare variable $aparecium:options 
   as map(xs:string, item()*)
   := map {
        'return-tree': true(),
        'return-pfg': false(),
        'return-items': false(),
        'return-grammar': false(),

        'tree-type': 'ast',
                'multiple-definitions': 'error',
        'undefined-symbols': 'error',
        'unreachable-symbols': 'silence',
        'unproductive-symbols': 'silence',
        'conformance': 'tolerant' 

      };
declare variable $aparecium:libloc as xs:string
  := '../lib';
declare variable $aparecium:ixml.ixml as xs:string
  := $aparecium:libloc || '/ixml.2022-05-28.ixml';

declare variable $aparecium:ixml.xml as xs:string
  := $aparecium:libloc || '/ixml.2022-05-28.01.inlined.xml';
  
declare variable $aparecium:ixml.gl.xml as xs:string
  := $aparecium:libloc || '/ixml.2022-05-28.inlined.compiled.xml';  

