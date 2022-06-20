module namespace epi =
"http://blackmesatech.com/2019/iXML/Earley-parser-internals";

(: Internals of Earley parser. :)
(: Not intended for user exposure. :) 

import module namespace er =
"http://blackmesatech.com/2019/iXML/Earley-recognizer"
at "Earley-recognizer.xqm";

import module namespace eri =
"http://blackmesatech.com/2019/iXML/Earley-rec-internals"
at "Earley-rec-internals.xqm";
  
declare namespace follow = 
"http://blackmesatech.com/2016/nss/ixml-gluschkov-automata-followset"; 

declare namespace ixml = 
"http://invisiblexml.org/NS";

declare namespace ap = 
"http://blackmesatech.com/2019/iXML/Aparecium";

(: We rely on the EXPath file module, and we use maps. :)
declare namespace file =
"http://expath.org/ns/file";

declare namespace map =
"http://www.w3.org/2005/xpath-functions/map";



(: ******************************************************
   earley-parse($I, $G, $f);  run Earley recognizer on 
   input $I and grammar $G, return results using 
   $f($leiClosure, $Ec, $I, $G)
:)
declare function epi:earley-parse(
  $I as xs:string,
  $G as element(ixml),
  $options as map(xs:string, item()*)?
) as item()* {
  let $dummy := eri:notrace((), 'epi:earley-parse() ...') 

  let $options := 
      if (empty($options))
      then map { 'return': 'any-tree',
                 'tree-count': 2,
                 'failure-dump': 'closure' }
      else $options

  let $mapResult := (:stat ...prof:time( ... tats:)
                    er:recognizeX($I, $G),
                    (:stat ...'0a recognize(): '),... tats:)

      $meiClosure := $mapResult('Closure'),
      $leiCompletions := $mapResult('Completions')

  let $leResults0 := if ($mapResult('Result'))
      then        if ($options?return = 'all-trees')
       then         let $dummy := eri:notrace((), 
                      'epi:earley-parse() has result') 

        let $lpt := (:stat ...prof:time(... tats:)
                    epi:all-trees($leiCompletions, $meiClosure, $I)
                    (:stat ..., '0b making trees: ')... tats:)
        let $dummy := eri:notrace((), 
                      'epi:earley-parse() returning a result') 
        for $rpt at $npt in $lpt
        return if ($options?tree-form eq 'raw')
        then $rpt
        else if ($options?tree-form eq 'both')
        then ($rpt, epi:astXparsetree($rpt, count($lpt)))
        else epi:astXparsetree($rpt, count($lpt))

       else if ($options?return = 'tree-cursor')
       then   <tree-cursor-not-available/>

       else if ($options?return = 'parse-forest-map')
       then   <parse-forest-map-not-available/>

       else if ($options?return = 'parse-forest-grammar')
       then         let $dummy := eri:notrace((), 
                      'epi:earley-parse() has result') 

        let $pfg := (:stat ...prof:time(... tats:)
                    epi:parse-forest-grammar($leiCompletions, $meiClosure, $I)
                    (:stat ..., '0b making pfg: ')... tats:)
        let $dummy := eri:notrace((), 
                      'epi:earley-parse() returning a parse-forest grammart') 
        return $pfg

       else (: default to any-tree :)
                    if ($options?tree-constructor eq 'direct')
        then 
        let $lpt := (:stat ...prof:time(... tats:)
                    epi:all-trees($leiCompletions, $meiClosure, $I)
                    (:stat ..., '0b making trees: ')... tats:)
        let $dummy := eri:notrace((), 
                      'epi:earley-parse() returning a result') 
        for $rpt in $lpt[1]
        return if ($options?tree-form eq 'raw')
        then $rpt
        else if ($options?tree-form eq 'both')
        then ($rpt, epi:astXparsetree($rpt, count($lpt)))
        else epi:astXparsetree($rpt, count($lpt))

        else 
        let $pfg := (:stat ...prof:time(... tats:)
                    epi:parse-forest-grammar($leiCompletions, $meiClosure, $I),
                    (:stat ...'0b making pfg: '),... tats:)
            $ast := (:stat ...prof:time(... tats:)
                    epi:tree-from-pfg($pfg, 'document', ())
                    (:stat ..., '0c extracting tree: ')... tats:)
		    
        let $dummy := eri:notrace((), 
                      'epi:earley-parse() returning a result') 

        return if (1 eq 0) (: debugging hack, delete sometime :)
        then element ap:wrap { 
                   element ap:ast { $ast }, 
                   element ap:pfg { $pfg }
        } 
        else $ast




      else  (: otherwise, send an apology and explanation :)
  let $closure := <Closure>{
      let $mei := $mapResult('Closure')
      for $n in map:keys($mei('to'))
      order by $n descending
      for $ei in $mei('to')($n)
      return eri:eXei($ei)
  }</Closure>

  let $high-water := $closure/item[1]/@to/number()
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
  <ap:no-parse xmlns:ixml="http://invisiblexml.org/NS" ixml:state="failed">
    <p>Sorry, no parse for this string and grammar.</p>
    <p>The parser gave up at character {$high-water}:
        parsing succeeded up through <q>{
          replace($sL,'&#xA;','&amp;#xA;')
        }</q>
        but failed on <q>{
          replace($sR, '&#xA;', '&amp;#xA;')
        }</q></p>
    <p>Expecting one of: {
        string-join(
           for $ei in $mapResult('Closure')('to')($high-water)
           for $sym in eri:lsymExpectedXEi($ei)[eri:fTerminal(.)]
           return concat('"', eri:reXTerminal($sym), '"'),
           ', ')
        }</p>{
    if ($options?failure-dump eq 'no')
    then ()
    else if ($options?failure-dump eq 'closure')
    then $closure    
    else if ($options?failure-dump eq 'yes')
    then <dump>
    <p>The map is:</p>
   
    <Initial-Item>{eri:eXei($mapResult('Initial-Item'))}</Initial-Item>
    <Input>{$mapResult('Input')}</Input>
    <Input-Length>{$mapResult('Input-Length')}</Input-Length>
    <Completions>{
       for $ei in $mapResult('Completions')
       return eri:eXei($ei)
    }</Completions>
    <Result>{$mapResult('Result')}</Result>
    <Closure>{$closure}</Closure>
    <grammar>{(: 'Omitted.' :) $mapResult('Grammar') }</grammar>
    </dump>
    else ()
  }</ap:no-parse>


  let $leResults := if ( ($G/prolog/version/@string
           /string(), "1.0")[1] eq "1.0")
      then $leResults0
      else for $item in $leResults0
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


  return $leResults
};

(: ******************************************************
   all-trees($Closure, $Ec, $I, $G):  
:)
declare function epi:all-trees(
  $leiCompletions as map(*)*,
  $meiClosure as map(xs:string,
                     map(xs:integer,
                         map(xs:string, item())*)) 
                 (:MEI:),
  $I as xs:string
  (: $G as element(ixml) :)
) as element()* {
  (: Call auxiliary routine with a vertical stack for
     loop prevention. :)
  epi:all-trees($leiCompletions, $meiClosure, $I, ())
};
(: ******************************************************
   all-trees#5:  auxiliary function (more args, does the 
   work) 
:)
   
declare function epi:all-trees(
  $leiCompletions as map(*)*,
  $meiClosure as map(xs:string,
                     map(xs:integer,
                         map(xs:string, item())*)) (:MEI:),
  $I as xs:string,
  $leiVStack as map(*)*
  (: $G as element(ixml) :)
) as element()* {
    for $Ec at $nEc in $leiCompletions
             [not(
               some $eiV in $leiVStack
               satisfies deep-equal(.,$eiV)
             )]
  
  let $dummy := eri:notrace($Ec,
    'all-trees called with item '
    || $nEc || ' (of ' || count($leiCompletions)
    || ') = ' || eri:sXei($Ec) 
  )

    let $parsetrees := epi:all-node-sequences(
    $Ec,
    $meiClosure,
    (),
    $Ec('from'), 
    $Ec('to'), 
    $I,
    ($Ec, $leiVStack),
    ()
  )
    for $parsetree in $parsetrees
  let $dummy := eri:notrace($parsetree,
    'all-trees got this parsetree back from item Ec = ' || eri:sXei($Ec))
  return $parsetree 

}; 

declare function epi:any-tree(
  $leiCompletions as map(*)*,
  $leiClosure as map(*)*,
  $I as xs:string
) as element()* {
  <any-tree-not-implemented-yet/>
};

declare function epi:tree-cursor(
  $leiCompletions as map(*)*,
  $leiClosure as map(*)*,
  $I as xs:string
) as element()* {
  <tree-cursor-not-implemented-yet/>
};

declare function epi:parse-forest-map(
  $leiCompletions as map(*)*,
  $leiClosure as map(*)*,
  $I as xs:string
) as map(*) {
  map { 'Result' : <parse-forest-map-not-implemented-yet/> }
};

declare function epi:parse-forest-grammar(
  $leiCompletions as map(*)*,
  $leiClosure as map(xs:string,
    map(xs:integer,
        map(xs:string, item())*)) ,
  $I as xs:string
) as element() {
  let $rules := epi:make-pfg-rules(
                    $leiCompletions,
                    $leiClosure,
		    $I, 
                    ())
		    
  return 
    
    (: if we got an error back, pass it along :)
        if ($rules/self::ap:error)
    then element ap:error {
           attribute id { "ap:tbd30" },
           element comment {
             "Failure generating PFG. ",
             "Sorry!" 
           },
           $rules                
           }


    (: if we are error-free, wrap it in ixml :)
    else element ixml {
           element comment {
             "Parse-forest grammar generated ",
             current-dateTime()
           },
           $rules                
         }

};
declare function epi:make-pfg-rules(
  $leiQueue as map(*)*,
  $leiClosure as map(xs:string,
    map(xs:integer,
        map(xs:string, item())*)) ,
  $I as xs:string,
  $leRules as element()*
    (: accumulator, element(rule|error)* :)
) as element()* {
    if (empty($leiQueue))
  then $leRules

  else 
  let $ei := head($leiQueue)
  
  let $dummy := eri:notrace(eri:sXei($ei), 'Making production rule for item: ')

  
  let $r0 := $ei('rule')
  let $w  := map { 'item': $ei, 
                   'state': 'q0',
                   'follow-states': 
                       tokenize($r0/@first),
                   'final': 
                       xs:boolean($r0/@nullable)
             }

  let $walks := epi:find-walks(
                  $ei       (: completion for parent :),
                  $leiClosure, 
                  $I, 
                  $w                        (: queue :),
                  if (xs:boolean($r0/@nullable)
                      and ($ei('from') eq $ei('to'))) 
                  then $w 
                  else ()             (: accumulator :),
                  map { 'tree-count': 2 } (: options :)
                )

   let $dummy := if (count($walks) gt 1)
                 then (eri:notrace(count($walks), 'Find-walks found # walks'
                       || ' for ' || eri:sXei($ei)),
                     for $w at $walknum in $walks 
                     return eri:notrace($w, 'Walk no. ' || $walknum || ' is:'))
                 else ()

    let $rule := element rule {
                   attribute name {
                       concat($r0/@name,
                           '·',
                           $ei('from'),
                           '·',
                           $ei('to') (: ,
                           '·',
                           $ei('ri') :)
                       )
                   },
                   $r0/@mark,
                   if (empty($walks))
                   then element ap:error {
		     attribute id { "ap:tbd21" },
                     element p { "In make-pfg-rules, " },
                     element p { "find-walks() failed." },
                     element p { "Here is what I know." },
                     element dump { 
                       element var {
                         attribute name { "ei" },
                         eri:eXei($ei)
                       },
                       element var {
                         attribute name { "ei?rule" },
                         $r0
                       },
                       element var {
                         attribute name { "closure" },
                         for $n in map:keys($leiClosure('to'))
  		         order by $n descending
  		         for $ei in $leiClosure('to')($n)
  		         return eri:eXei($ei)
                       }
                     }
                   } 
                   else for $w in $walks
                   return element alt { 
                       epi:rhs-from-walk($w, $I, ())
                   }
               }

  
  let $lei0 := for $w in $walks
               return epi:lei-from-walk($w, ()), 
               (: all completion items in $walks :)
	       
      $lei1 := $lei0[
                 not(some $i in 1 to (position() - 1)
                  satisfies deep-equal(., $lei0[$i]) 
                  (: satisfies .?sig eq $lei0[$i]?sig :)
		  (: satisfies ((.?from eq $lei0[$i]?from)
                    and      (.?to   eq $lei0[$i]?to  )
                    and deep-equal(
                              .?rule,   $lei0[$i]?rule)) :)
                 )
               ],
               (: list of distinct completion items :)

      $lei2 := $lei1[
                 not(some $i in 2 to (count($leiQueue))
                   satisfies deep-equal(., $leiQueue[$i]) 
                   (: satisfies .?sig eq $leiQueue[$i]?sig   :)
		   (: satisfies ((.?from eq $lei0[$i]?from)
                     and      (.?to   eq $lei0[$i]?to  )
                     and deep-equal(
                              .?rule,   $lei0[$i]?rule)) :)
                 )
               ]
               (: completion items not in the queue :)

  let $ls-defined := ($leRules, $rule)
                     /@name/string(),

      $lei3 := for $ei in $lei2
               let $s := $ei('rule')/@name/string()
                         || '·'
                         || $ei('from')
                         || '·'
                         || $ei('to') (:
                         || '·'
                         || $ei('ri') :)
               where not($s = $ls-defined)
               return $ei
               (: new completion items, 
                  not in queue and not already done :)

  let $new-queue := (tail($leiQueue), $lei3)


    return epi:make-pfg-rules(
           $new-queue,
           $leiClosure,
           $I,
           ($leRules, $rule)
         )


};

declare function epi:find-walks(
  $eiParent as map(*),
  $mei as map(xs:string,
    map(xs:integer,
        map(xs:string, item())*)) ,
  $I as xs:string,
  $queue as map(xs:string, item()*)*
,
  $acc as map(xs:string, item()*)*
,
  $options as map(*)
) as map(xs:string, item()*)*
 {
    if (($options('tree-count') ne -1)
      and 
      (count($acc) ge $options('tree-count')))
  then $acc
  else if (empty($queue))
  then $acc

  else 
  
  let $new-queue := 
      for $w in $queue
      let $x := if ($w?state eq 'q0')
                then $w('item')('from')
                else $w('item')('to'),
          $qqNext := $w('follow-states')

      for $qNext in $qqNext
      let $symbol := $eiParent('rule')//*[@xml:id=$qNext],
          $N := $symbol/self::nonterminal/@name/string(),
          $T := $symbol[eri:fTerminal(.)]/@xml:id/string(),
	  $symbol-mark := $symbol/(@mark, @tmark)/string()

      let $dummy := if (exists($T)) then eri:notrace($T,
          'find-walks: seeking completion items for this terminal:')
          else ()

      group by $x, $qNext, $N, $T

      let $items0 := $mei('from')($x)
                     [(.?rule/@name eq $N)
                      or (.?rule/@xml:id eq $T)]
                     [eri:fFinalEi(.) 
                      or (.?ri eq '#terminal')]
                     [.?to le $eiParent('to')],
          $items  := for $i at $index in $items0
                     where not(
                       some $j in 1 to ($index - 1) 
                       satisfies (
                         $items0[$j]?from eq $i?from
                         and 
                         $items0[$j]?to eq $i?to
                         and deep-equal(
                           $items0[$j]?rule, $i?rule
                         )
                       )
                     )
                     return $i


      for $i in $items
      let $fNull := ($i('to') eq $i('from')),
          $leiDups := if ($fNull)
                      then epi:dups-from-walk(
                               $qNext, $i, $w[1], ()
                           )
                      else ()

      let $qqNextfollow := tokenize(
                               $eiParent('rule')
                               /attribute::follow:*
                               [local-name() eq $qNext]
                           ),
          $f-qnext-final := ($qNext = 
                           eri:lriFinalstatesXR(
                               $eiParent('rule')
                           ))

      return if ($fNull and count($leiDups) gt 1)
      then ()
      else map {
                 'item' : $i,
                 'state' : $qNext,
                 'follow-states' : $qqNextfollow,
                 'final' : $f-qnext-final,
                 'mark'  : $symbol-mark,
                 'pred'  : $w[1]
             }


  
  let $new-acc := ($acc, $new-queue
                         [ .?final ]
                         [ .?item?to eq $eiParent?to ])


  return epi:find-walks(
      $eiParent, 
      $mei,
      $I,
      $new-queue,
      $new-acc,
      $options
  )
};

declare function epi:rhs-from-walk(
  $w as map(xs:string, item()*)
?,
  $I as xs:string,
  $acc as element()*
) as element()* {

    if (empty($w) or ($w('state') eq 'q0')) 
  then $acc

  else   if ($w('item')('ri') eq '#terminal')
  then let $ei := $w('item')
       let $x := $ei('from'),
           $y := $ei('to'),
           $symbol := element literal {
               attribute tmark { $w('mark') },
               attribute string {
                   substring($I, $x+1, ($y - $x))              
               }
           },

           $new-acc := ($symbol, $acc),
	   $next-step := $w('pred')
       return epi:rhs-from-walk($next-step, $I, $new-acc)

  else   if (exists($w('item')('rule')/self::rule[@name]))
  then let $ei := $w('item'),

           $symbol := element nonterminal {
               attribute name {
                   $ei('rule')/@name/string()
                   || '·'
                   || $ei('from')
                   || '·'
                   || $ei('to') (:
                   || '·'
                   || $ei('ri') :)
               },
               if (exists($w('mark')))
               then attribute mark { $w('mark') }
               else ()
           },
           $new-acc := ($symbol, $acc),
           $next-step := $w('pred')
       return epi:rhs-from-walk($next-step, $I, $new-acc)

  else 
let $dummy := eri:trace($w('item'), 'rhs-from-walk:  item fell through!') return
       element ap:error {
           attribute id { "ap:tbd25" },
           element p { 'Unexpected disaster 83' },
           $acc,
           $w?state
       }

};

declare function epi:lei-from-walk(
  $w as map(xs:string, item()*)
?,
  $acc as map(*)*
) as map(*)* {
  if (empty($w)) 
  then $acc
  else if ($w('state') eq 'q0')
  then $acc
  else if ($w('item')('ri') eq '#terminal')
  then epi:lei-from-walk($w('pred'), $acc)
  else epi:lei-from-walk($w('pred'),
                         ($w('item'), $acc))
};

declare function epi:dups-from-walk(
  $q as xs:string,
  $ei as map(*),
  $w as map(xs:string, item()*)
?,
  $acc as item()*
) as map(xs:string, item()*)*
 {
  if (empty($w)) 
  then $acc
  else if ($w('state') eq 'q0')
  then $acc
  else if ( 
            (: $ei?sig eq $w?item?sig :)
            deep-equal($ei, $w('item')) 
            and 
            $q eq $w('state')
          )
  then epi:dups-from-walk($q, $ei, $w('pred'), ($w, $acc))
  else epi:dups-from-walk($q, $ei, $w('pred'), $acc)
};



declare function epi:tree-from-pfg(
  $pfg as element() 
      (: ixml, rule, alt, nonterminal, literal :),
  $nodetype as xs:string,
  $mark as xs:string?
) as node()* {
  if ($pfg/self::ixml)
  then 
      let $f-ambig := exists($pfg//rule[count(alt) gt 1]),
          $tree0 := epi:tree-from-pfg(
                        $pfg/rule[1]/alt/nonterminal,
                        'element',
                        ()
                    ),
          $tree1 := if (exists($tree0
                       /descendant-or-self::ap:error))
                    then element ap:error {
                           attribute ixml:state { "failed" },
                           attribute id { "ap:tbd31" },
                           attribute code { "ixml:D01" },
                           attribute ap:desc { "Dynamic error: ill-formed output" },
                           $tree0
                         }
                    else $tree0
      return if (not($f-ambig))
             then $tree1
             else element { name($tree1) } {
                     attribute ixml:state { 
                        "ambiguous" ,
                        $tree1/@ixml:state
                     },
                     ($tree1/attribute::* 
                       except $tree1/@ixml:state),
                     $tree1/child::node()
                  }

  else if ($pfg/self::rule)
  then 
      if ($pfg/ap:error)
      then $pfg
      else
      let $mark := ($mark, 
                    $pfg/@mark/string(),
                    '^')[1]
      let $n := count($pfg/alt),     
          $ran := (: What random number function is available? :)
let $f1 := function-lookup(
              QName('http://basex.org/modules/random', 
                    'integer'), 
              1),
    $f2 := function-lookup(
              QName('http://exslt.org/random', 
                    'random-sequence'), 
           2),
    $f3 := function-lookup(
              QName('http://exslt.org/math', 
                    'random'), 
           0)

return 

(: basex random:integer() :)
if (exists($f1)) 
then $f1($n)

(: exslt-random:random-sequence() returns fraction 
   in 0..1; multiply by $n and take the floor to
   get the number we need :)
else if (exists($f2)) 
then let $frac := $f2(1,seconds-from-dateTime(current-dateTime()))
     return if ($frac eq 1) 
            then 0 
            else floor($frac * $n)

(: exslt-math:random(); use same procedure :)
else if (exists($f3)) 
then let $frac := $f3()
     return if ($frac eq 1) 
            then 0 
            else floor($frac * $n)

else error(QName(
"http://blackmesatech.com/2019/iXML/Aparecium",
"tbd17"), 'No random number generator found!')
,
          $i := 1 + $ran,
          $ccc := $pfg/alt[$i]/*,
          $ls0 := tokenize($pfg/@name, '·'),
          $nm0 := $ls0[1],
          $fr  := $ls0[2],
          $to  := $ls0[3],
          $nm  := if ($nm0 castable as xs:Name)
                  then $nm0
                  else xs:QName('ap:error')
      return if (($nodetype = ('element', 'content'))
                 and ($mark eq '^'))
          then element { $nm } {
                   if ($nm0 ne $nm)
                   then (attribute id { "ixml:D03"}, 
                         attribute ap:gi { $nm0 })
                   else (),
                   
                   let $lnAtts := 
                      for $c in $ccc
                      return epi:tree-from-pfg(
                                 $c, 
                                 'attribute',
                                 ()
                      )
let $dummy := eri:notrace(count($lnAtts), 'Gathering attributes, found #: ')
let $dummy := eri:notrace($lnAtts, 'Gathering attributes, found these: ')
                   let $lnAok := 
                       $lnAtts
                       [every $i in 1 to (position() - 1)
                        satisfies
                        $lnAtts[$i]/name() ne ./name()]
let $dummy := eri:notrace(count($lnAok), 'Of these some are OK: ')
	           let $lnAdups := $lnAtts
                       [some $i in 1 to (position() - 1)
                        satisfies
                        $lnAtts[$i]/name() eq ./name()]
let $dummy := eri:notrace(count($lnAdups), 'Of these some are dups: ')
                   return ($lnAok,
		       for $n in $lnAdups
                       return element ap:error {
                          attribute id { "ap:tbd32" },
                          attribute code { "ixml:D02" },
                          $n,
                          "Dynamic error: Duplicate attribute name"
                       })
,
                                      for $c in $ccc
                   return epi:tree-from-pfg(
                              $c, 
                              'content',
                              ()
                   )

               }

          else if (($nodetype = ('attribute'))
                 and ($mark eq '@'))
          then attribute { $nm } {
                   if ($nm0 ne $nm)
                   then text { concat('[', $nm0, ']=') }
                   else (),
		   (: hack :)
                   string-join(
                   for $c in $ccc
                   let $node := epi:tree-from-pfg(
                              $c, 
                              'value',
                              ()
                   )
                   return $node
                   , '')
               }

          else if (($nodetype = ('content', 'element', 'attribute'))
                 and ($mark eq '-'))
          then for $c in $ccc
               return epi:tree-from-pfg(
                          $c, 
                          $nodetype,
                          ()
               )

          else if (($nodetype = ('value')))
          then for $c in $ccc
               return epi:tree-from-pfg(
                          $c,
                          'value',
                          ()
               ) 

          else if (($nodetype = ('content'))
                 and ($mark = ('@')))
          then ()
          else if (($nodetype = ('attribute'))
                 and ($mark = ('^')))
          then ()

          else if (($nodetype = ('element'))
                 and ($mark = ('@')))
          then element ap:error {
                 attribute id { "ap:tbd33" },
                 attribute code { "ixml:D05" },
                 attribute ap:desc {
                   "Attribute cannot be root.",
                   if ($nm ne $nm0)
                   then "&#xA;Also, the attribute"
                        || " name is not a legal"
                        || " XML name."
                   else ()
                 },
                 attribute ap:attribute-name {
                   $nm0
                 },
                 attribute ap:attribute-value {
                   for $c in $ccc
                   return epi:tree-from-pfg(
                              $c,
                              'value',
                              ()
                   )
                 }
               }
          else element ap:error {
            attribute id { "ap:tbd20" },
            "Ran off a cliff, ",
            "I don't remember a thing. ",
            "Nodetype is '" || $nodetype || "'",
            "and mark is '" || $mark || "'."
          }


  else if ($pfg/self::alt)
  then       for $c in $pfg/*
      return epi:tree-from-pfg($c, $nodetype, ())

  else if ($pfg/self::nonterminal)
  then 
      let $nt := $pfg/@name/string(),
          $rule := $pfg/ancestor::ixml[1]
                   /rule[@name eq $nt]
      return epi:tree-from-pfg($rule, 
                   $nodetype, 
                   $pfg/@mark/string())

  else if ($pfg/self::literal)
  then        let $s := if (exists($pfg/@string))
           then string($pfg/@string)
           else if (exists($pfg/@hex))
           then eri:charXhex($pfg/@hex)
           else '&#x1D350;' (: tetragram for failure U+1D350 :)

       return if ($pfg/@tmark eq '-') 
              then ()
              else if ($nodetype = ('element', 'attribute'))
              then () (: is this an error? :)
              else text { $s }

  else element eek {
      element desc {
          "tree-from-pfg got "
          || "an unexpected argument."
      },
      eri:trace($pfg, 'Unexpected argument!')
  }
};

(: ******************************************************
   epi:all-node-sequences($item, $closure, 
                          $acc, 
                          $from, $to, $I)
:)
declare function epi:all-node-sequences(
  $Ecur as map(*),
  $meiClosure as map(xs:string, 
                     map(xs:integer, 
                         map(xs:string, 
                             item())*)),
  $lnAcc as item()*,
  $pFrom as xs:integer,
  $pTo as xs:integer,
  $I as xs:string,
  $leiVStack as map(*)*,
  $leiHStack as map(*)*
) as element()* {
  
  let $dummy := eri:notrace(eri:sXei($Ecur),
    'all-node-seqs (0) called with Ecur:')
  return 
    (: 1. Before anything else, loop detection:  have we already 
     dealt with this item, in this sequence of nodes? :)
  if (some $eiH in $leiHStack satisfies deep-equal($Ecur, $eiH) )
  then let $dummy := eri:notrace(eri:sXei($Ecur),
           'all-node-seqs (case 1) returns empty sequence, '
           || 'current item has been seen before.')
       return ()

    (: 2. Base case:  $Ecur is initial. :)
  else if ($Ecur('ri') = 'q0'
      and $Ecur('from') eq $Ecur('to')
      and $Ecur('from') eq $pFrom)
  then 
    let $e := element nt {
                 $Ecur('rule')/@name,
                 attribute _from { $pFrom }, 
                 attribute _to { $pTo }, 
                 ( $Ecur('rule')/descendant::*
                                [@xml:id = $Ecur('ri')]
				/@mark
                   ,
                   $Ecur('rule')/@mark,
		   attribute mark { '^' }
                 )[1],
                 $lnAcc
               },
        $trace := eri:notrace(eri:sXei($Ecur),
                      'all-node-seqs (case 2) returns element ' 
		      || 'named ' || name($e) || ' for Ecur:')
    return $e

    (: 3. Recursive case. :)
  else (: 3. $Ecur('ri') is not a q0 / initial state :)
    (: 3.a some preparation common to T and N alike :)
    let $riCur := $Ecur('ri'),
        $sym := $Ecur('rule')/descendant::*[@xml:id = $riCur],
        $nParent := $Ecur('rule')/@name/string()
    return
            (: 3.b current $sym is terminal :)
      if (eri:fTerminal($sym)) then
         let $trace := eri:notrace(eri:sXei($Ecur),
                       'all-node-seqs (case 3b) '
                       || 'unscanning terminal symbol '
		       || $riCur) 
         let $cSymlength := eri:match-length($sym),
             $pMedial := xs:integer($Ecur('to')) - $cSymlength,
             $leiPrev := $meiClosure('to')($pMedial)[ 
                eri:fScanrelEE(.,$Ecur)
                (: and xs:integer(.('to')) eq $pMedial :)
             ],
	     $sVal := substring($I,$pMedial+1,$cSymlength),
	     
             $textnode := element { 
                (: Rename the terminal to reduce confusion
                between grammar and parse tree :)
                if ($sym/self::inclusion) 
                then 'incl' 
                else if ($sym/self::exclusion) 
                then 'excl' 
                else if ($sym/self::literal)
                then 'lit' 
		else 'terminal---'
	     } {
	        $sym/@xml:id, 
		$sym/@tmark,
	        $sym/@regex, 
		attribute string { $sVal },
		attribute cps { string-to-codepoints($sVal) }
             }

         (: recur on each possible previous node :)
         for $eiPrev in $leiPrev
         let $trace := if (count($leiPrev) gt 1)
	               then eri:notrace(eri:sXei($Ecur),
                            'all-node-seqs (case 3b) finds '
			    || count($leiPrev)
                            || ' predecessors, now recurring on eiPrev='
			    || eri:sXei($eiPrev))
		       else eri:notrace(eri:sXei($Ecur),
                            'all-node-seqs (case 3b) finds '
		            || count($leiPrev)
                            || ' predecessors, now recurring on eiPrev='
			    || eri:sXei($eiPrev))

         return epi:all-node-sequences($eiPrev,
                                       $meiClosure,
                                       ($textnode, $lnAcc),
                                       $pFrom,
                                       $pTo,
                                       $I,
                                       $leiVStack,
                                       ($Ecur, $leiHStack)
                                      )

            (: 3.c current $sym is nonterminal :)
      else if ($sym/self::nonterminal) then 
         let $trace := eri:notrace(eri:sXei($Ecur), 
                       'all-node-seqs (case 3c) '
		       || 'trying to unparse nonterminal '
		       || $riCur) 
                  let $leiPrev := $meiClosure('to')($Ecur('to'))[
           eri:fFinalEiPN(.,$Ecur('to'),$sym)
         ]

                  for $eiCC at $nEiCC in $leiPrev
         let $trace := eri:notrace(eri:sXei($Ecur),
	       'all-node-seqs (case 3c) finds completion item '
               || '(' || $nEiCC || ' of '
	       || count($leiPrev) || ')'
               || ' for ' || $sym/@name
	       || ', namely ' || eri:sXei($eiCC)
	       || ' and calls all-trees for it.')
         let $lnodeChild := epi:all-trees($eiCC,
                                          $meiClosure,
	                                  $I,
					  $leiVStack), 
             $leiPredictors := $meiClosure('to')($eiCC('from'))
	                       [eri:fAdvanceNrelEE(.,$Ecur)
                                (: and .('to') eq $eiCC('from') :)]

	 (:
         let $trace := for $nCh in $lnodeChild
                       return eri:notrace($nCh,
                              'all-node-seqs got this back'
			      || ' from all-trees:') 
         :)

                  for $eiPred at $nEiP in $leiPredictors
         let $trace := eri:notrace(eri:sXei($Ecur),
	       'all-node-seqs (case 3c) finds predictor '
               || '(' || $nEiP || ' of '
	       || count($leiPredictors) || ')'
               || ' for ' || $sym/@name
	       || ', namely ' || eri:sXei($eiPred))
         
         for $nodeCh0 at $nNch in $lnodeChild
                  let $nodeCh := 
             if (exists($sym/@mark)) 
             then element { name($nodeCh0) } {
	         $nodeCh0/(@* except @mark), 
	         $sym/@mark,
		 $nodeCh0/node()
	     }
             else $nodeCh0

         let $trace := eri:notrace(eri:sXei($Ecur),
	       'all-node-seqs recurs on child'
               || '(' || $nNch
	       || ' of ' || count($lnodeChild) || '),'
               || ' (predictor' || $nEiP
	       || ' of ' || count($leiPredictors) || '),'
               || ' (Completion' || $nEiCC
	       || ' of ' || count($leiPrev) || '),'
			   )

         return epi:all-node-sequences($eiPred,
                                       $meiClosure,
                                       ($nodeCh, $lnAcc),
                                       $pFrom,
                                       $pTo,
                                       $I,
                                       $leiVStack,
                                       ($Ecur, $leiHStack)
                                      )


            else (: not terminal, not nonterminal, we have a problem :)
        <error-in-all-node-sequences
          from="{$pFrom}" to="{$pTo}">{
            eri:sXei($Ecur)
          }</error-in-all-node-sequences>

  
};

declare function epi:astXparsetree(
  $E as element(nt),
  $cpt as xs:integer
) as node()* {
  if (empty($E/nt)) 
  then
      element ap:error {
          attribute id { "ap:tbd24" },
          text {
              "Parse tree had wrapper",
              "but no content."
          }
      }
  else
      let $doc0 :=
              for $c in $E/*
              return epi:doc-elementXpt($c),
          $doc1 :=
	      if (count($doc0) eq 1) 
              then $doc0 
	      else if (count($doc0) eq 0) 
              then element ixml:no-roots {}
	      else element ixml:multiple-roots {
	          $doc0
	      }
      return
          if ($cpt eq 1) 
          then $doc1
	  else element { name($doc1) } {
	       attribute ixml:state { 'ambiguous' },
	       $doc1/@*, 
	       $doc1/node()
	  }
};
declare function epi:doc-elementXpt(
  $E as element()*
) as node()* {
  (: Normal case :)
  if ($E/self::nt[@mark = '^' or not(@mark)]) 
  then epi:elementXpt($E)
  
  (: Hidden wrapper, recur :) 
  else if ($E/self::nt[@mark = '-']) 
  then for $c in $E/*
      return epi:doc-elementXpt($c) 

  (: Attribute (sic) :) 
  else if ($E/self::nt[@mark = '@']) 
  then element { $E/@name } {
      attribute ixml:warning {
          'Attribute found as root of AST'
      }
  }

  (: Terminal (sic) :) 
  else if ($E/self::*[name() = ('lit', 'incl', 'excl')])  
  then element ixml:terminal {
      attribute warning { 
          'Terminal found as root of AST'
      }, 
      text { if ($E/@tmark = '-')  
       then ()  
       else codepoints-to-string(
               for $t in tokenize(
                   normalize-space($E/@cps),
	           '\s')  
               return xs:integer($t)
       )
 } 
  }
  
  (: Unexpected input: what? :)
  else <oops>{$E}</oops>
};

declare function epi:elementXpt(
  $E as element()
) as node()* {
  element { $E/@name } {
      if ($E/@mark = ('-', '@'))
      then attribute ixml:warning {
          'Wrong mark (' || $E/@mark 
          || ') on nonterminal'
      }
      else (),
      for $c in $E/*
      return epi:attributesXpt($c), 
      for $c in $E/*
      let $dummy := eri:notrace(
          concat(name($c), '/', $c/@name, '/', $c/@xml:id),
          'constructing content from:') 
      let $n := epi:contentXpt($c)
      let $dummy := for $chunk in $n return
          if ($chunk instance of text())
          then eri:notrace(concat('/',
	       string-join(string-to-codepoints($chunk),' '), 
               '/'), 
               'eXpt got text node') 
          else if ($chunk instance of element())
	  then eri:notrace($chunk/name(), 'eXpt gets element:') 
	  else eri:notrace($chunk, 'eXpt gets unknown item:') 
      return $n
  }
};

 
declare function epi:attributesXpt(
  $E as element()
) as attribute()* {
  (: Main case: make an attribute :)
  if ($E/self::nt[@mark = '@']) 
  then attribute { $E/@name } {
      string-join(
          (for $c in $E/*
          return epi:avXpt($c)),
	  '')
  }

  (: skip terminals and elements :)
  else if ($E/name() = ('lit', 'incl', 'excl')) 
  then () 
  else if ($E/self::nt[@mark = '^' or not(@mark)])
  then ()

  (: recur through hidden nt :)
  else if ($E/self::nt[@mark = '-']) 
      then for $c in $E/*
      return epi:attributesXpt($c)

  else eri:trace((),
      '! unexpected argument to attributesXpt()') 
     
};

declare function epi:avXpt(
  $E as element()
) as xs:string* {
  if ($E/(self::incl or self::excl or self::lit))
  then if ($E/@tmark = '-')  
       then ()  
       else codepoints-to-string(
               for $t in tokenize(
                   normalize-space($E/@cps),
	           '\s')  
               return xs:integer($t)
       )
 
  else for $c in $E/*
       return epi:avXpt($c)
};

declare function epi:contentXpt(
  $E as element()
) as item()* {
  if ($E/self::nt[@mark = '^' or not(@mark)])
  then epi:elementXpt($E)
  else if ($E/self::nt[@mark = '-'])
  then for $c in $E/*
       return epi:contentXpt($c)
  else if ($E/self::nt[@mark = '@'])
  then ()
  else if ($E[self::incl or self::excl or self::lit])
  then text { if ($E/@tmark = '-')  
       then ()  
       else codepoints-to-string(
               for $t in tokenize(
                   normalize-space($E/@cps),
	           '\s')  
               return xs:integer($t)
       )
 }
  else element ixml:unexpected {
       attribute f { "epi:contentXpt" }, 
       $E
  }
};


