module namespace ep =
"http://blackmesatech.com/2019/iXML/Earley-parser";

(: The top-level definition of an Earley parser. :)

import module namespace epi =
"http://blackmesatech.com/2019/iXML/Earley-parser-internals"
at "Earley-parser-internals.xqm";

import module namespace er =
"http://blackmesatech.com/2019/iXML/Earley-recognizer"
at "Earley-recognizer.xqm";

import module namespace eri =
"http://blackmesatech.com/2019/iXML/Earley-rec-internals"
at "Earley-rec-internals.xqm";

import module namespace d2x = 
'http://blackmesatech.com/2019/iXML/d2x'
at "d2x.xqm";

declare namespace ap = 
"http://blackmesatech.com/2019/iXML/Aparecium";

declare namespace ixml = 
"http://invisiblexml.org/NS";

declare namespace map = 
"http://www.w3.org/2005/xpath-functions/map";

(: Goal:  to return the set of parse trees recorded implicitly in the
   Earley closure.
   :)
declare function ep:parse(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :),
  $options as map(*)
) as element() {

  let $map := (:stat ...prof:time( ... tats:)
              er:recognizeX($I, $G, $options),
              (:stat ...'0a recognize(): '),... tats:)
      $completion-item := $map('Completions'),
      $pfg := 
              (:stat ...prof:time(... tats:)
              if (exists($map('Completions')))
              then epi:parse-forest-grammar(
                       $map('Completions'), 
                       $map('Closure'), 
                       $I,
                       $options)
              else element ap:no-pfg {
                "Parse failed, no parse-forest grammar."
              }
              (:stat ..., '0b making pfg: ')... tats:)
,
      $dynamic-errors :=       for $ins in $pfg//insertion[@hex]
      let $int := d2x:x2d($ins/@hex)
      let $sval := try {
                       codepoints-to-string($int)
                   } catch err:FOCH0001 {
                       'FOCH0001'
                   } catch * {
                       'other-hex-error'
                   }
      return if ($sval eq "FOCH0001")
             then element ap:error {
                    attribute id { "ap:tbd39" },
                    attribute code { "ixml:D04" },
                    "Hex value ", $ins/@ex/string(), 
                    "( = " || string($int) || ")", 
                    "in the definition of", 
                    $ins/ancestor::rule/@name/string(),
                    "is not an XML character."
             }
             else if ($sval eq "other-hex-error")
             then element ap:error {
                    attribute id { "ap:tbd40" },
                    attribute code { "ixml:D04" },
                    "Hex value ", $ins/@ex/string(), 
                    "( = " || string($int) || ")", 
                    "in the definition of", 
                    $ins/ancestor::rule/@name/string(),
                    "is not an XML character."
             }
             else ()
,
      $ast0 :=               (:stat ...prof:time(... tats:)
              if (exists($pfg/self::ixml))
              then epi:tree-from-pfg($pfg, 'document', ())
              else   let $high-water := max(map:keys($map('Closure')('to')))
  let $start := max((1, (1 + $high-water - 30))),
      $end := min((string-length($I),
                   ($high-water + 30))),
      $cL := min(($high-water, 30)),
      $cR := min(($end - $high-water, 30)),
      $sL := concat(if ($high-water gt 30)
                    then '...'
                    else '',
                    substring($I, $start, $cL)
             ),
      $sR := concat(substring($I, $high-water+1, 30 (: $cR :) ),
                    if ($cR lt 30)
                    then ''
                    else '...'
             )
  return     
  element ap:no-parse {
    attribute ixml:state { "failed" },
    element p { 
      "Sorry, no parse for this string and grammar." 
    },
    element p {
      "The parser gave up at character",
      string($high-water) || ":
",
      "parsing succeeded up through ", 
      element q {
          replace($sL,'&#xA;','&amp;#xA;')
      },
      "
but failed on ",
      element q {
          replace($sR, '&#xA;', '&amp;#xA;')
      }
    },
    element p {
      "Expecting one of: ",
      string-join(
           for $ei in $map('Closure')('to')($high-water)
           for $sym in eri:lsymExpectedXEi($ei)[eri:fTerminal(.)]
           return concat('"', eri:reXTerminal($sym), '"'),
           ', '
      )
    }
  }

              (:stat ..., '0c extracting tree: ')... tats:)

,
      $ast1 :=       if (empty($ast0))
      then element ap:dynamic-error {
             attribute id { "ap:tbd44" },
             attribute code { "???" },
             element ap:empty-parse-tree {
               $ast0
             }
      }  
      else if (count($ast0) gt 1)
      then element ap:dynamic-error {
             attribute id { "ap:tbd41" },
             attribute code { "ixml:D06" },
             element ap:multiple-roots {
               $ast0
             }
      }  
      else if ($ast0 instance of attribute())
      then element ap:dynamic-error {
             attribute id { "ap:tbd42" },
             attribute code { "ixml:D05" },
             element ap:attribute-root {
               $ast0
             }
      }  
      else if ($ast0 instance of text())
      then element ap:dynamic-error {
             attribute id { "ap:tbd43" },
             attribute code { "ixml:D06" },
             element ap:no-element-at-root {
               $ast0
             }
      } 
      else if (($ast0 instance of document-node())
               and 
               (count($ast0/*) eq 0)
              )
      then element ap:dynamic-error {
             attribute id { "ap:tbd43b" },
             attribute code { "ixml:D06" },
             element ap:no-element-root {
               $ast0
             }
      }  
      else if (($ast0 instance of document-node())
               and 
               (count($ast0/*) gt 1)
              )
      then element ap:dynamic-error {
             attribute id { "ap:tbd41b" },
             attribute code { "ixml:D06" },
             element ap:multiple-roots {
               $ast0
             }
      }  
      else if (count($ast0/descendant-or-self::*
               /attribute::*
               [starts-with(lower-case(name()), 'xml')])
	       gt 0
              )
      then element ap:dynamic-error {
             attribute id { "ap:tbd45" },
             attribute code { "ixml:D07" },
             element ap:description {
               "Names beginning 'xml' are reserved."
             },
             element ap:reserved-name {
               $ast0
             }
      }  
      else $ast0
,
      $ast2 := if ( ($G/prolog/version/@string
           /string(), "1.0")[1] eq "1.0")
      then $ast1 (: $leResults0 :)
      else for $item in $ast1 (: $leResults0 :)
           return if ($item instance of element())
           then element {name($item)} {
                  ($item/@* except 
                    ($item/@ixml:state,
                     $item/@ap:version-string,
                     $item/@ap:version-used)),
                  attribute ixml:state {
                    $item/@ixml:state/string(),
                    'version-mismatch'
                  },
                  attribute ap:version-string {
                    string($G/prolog/version/@string)
                  },
                  attribute ap:version-used {
                    "1.0"
                  },
                  $item/child::node()
                }
           else $item
,
      $ast  := if (count($dynamic-errors) gt 1)
               then element ap:dynamic-errors {
                      $dynamic-errors
                    }
               else if (count($dynamic-errors) eq 1)
               then $dynamic-errors
               else $ast2

  return if ($options('return-tree') 
            and not($options('return-pfg'))
            and not($options('return-items'))
            and not($options('return-grammar')))
      then $ast
      else element ap:results {
               if ($options('return-tree'))
               then element ap:ast { $ast }
               else (),
               if ($options('return-pfg'))
               then element ap:pfg { $pfg }
               else (),
               if ($options('return-items'))
               then element ap:items { 
                      let $mei := $map('Closure')
                      for $n in map:keys($mei('to'))
                      order by $n descending
                      for $ei in $mei('to')($n)
                      return eri:eXei($ei)
                    }
               else (),
               if ($options('return-grammar'))
               then element ap:compiled-grammar { 
                        $map('Grammar')
                    }
               else ()
           }

};

