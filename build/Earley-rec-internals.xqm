module namespace ixi =
"http://blackmesatech.com/2019/iXML/Earley-rec-internals";

(: Earley recognizer internals :)

declare namespace map =
"http://www.w3.org/2005/xpath-functions/map";

(: ****************************************************** 
   * Imports and setup
   ****************************************************** :)

import module namespace ix =
"http://blackmesatech.com/2019/iXML/Earley-recognizer"
at "Earley-recognizer.xqm";
  
import module namespace d2x =
'http://blackmesatech.com/2019/iXML/d2x'
at "d2x.xqm";
  
declare namespace follow = 
"http://blackmesatech.com/2016/nss/ixml-gluschkov-automata-followset";

(: $ixi:combinedups:  convenience variable for calls to 
   map:merge. :)
declare variable $ixi:combinedups as map(*)
   := map:entry('duplicates','combine');
   
(: ****************************************************** 
   * Earley items
   ****************************************************** :)
(: We represent an Earley item as a map with keys 'from', 
   'to', 'rule', and 'ri' (rule index).  For any item $ei, 
   $ei('from') and $ei('to') are integers, $ei('rule') is 
   element(rule), and $ei('ri') is a string (an NCName, 
   in fact, but typed only as a string).
:)

(: ******************************************************
   * Earley items:  constructors
  :)

(: ......................................................
   ei Make P P R Ri: make an Earley item from two 
   positions, a rule, and a rule index
  :)
declare function ixi:eiMakePPRRi(
  $From as xs:integer,
  $To as xs:integer,
  $r as element(rule),
  $ri as xs:string
) as map(xs:string, item()) {  
  map {
    'from' : $From,
    'to' : $To,
    'rule' : $r,
    'ri' : $ri
  }
};
(: ......................................................
   ei Make P P T: make an Earley item from two 
   positions and a terminal.
  :)
declare function ixi:eiMakePPT(
  $From as xs:integer,
  $To as xs:integer,
  $t as element()
) as map(xs:string, item()) {  
  map {
    'from' : $From,
    'to' : $To,
    'rule' : $t,
    'ri' : "#terminal"
  }
};

(: ......................................................
   ixi:lei Advance Ei Sym P($E, $sym, $p): return the 
   set of Earley items (lei) that arise if you advance 
   $E over $sym, or over any equivalent symbol, to reach 
   position $p.
:)
declare function ixi:leiAdvanceEiSymP(
  $E as map(xs:string, item()),
  $sym as element(),
  $pNew as xs:integer
) as map(xs:string, item())* {
  let $pFr := $E('from'),
      $pTo := $E('to')
  return if ($pNew lt xs:integer($pTo))
      then () (: $E cannot advance backwards :)
      else 
  let $r := $E('rule'),
      $ri0 := $E('ri'),
      $lriFollow := if ($ri0 eq 'q0')
                    then $r/@first
                    else $r/@follow:*[local-name() = $ri0],
      $lri := tokenize($lriFollow,'\s+')[normalize-space()]
  for $ri in $lri
  where ixi:fSymbolmatchRRiSym($r,$ri,$sym)
    (: and $pNew ge xs:integer($pTo) :)
  return ixi:eiMakePPRRi($pFr, $pNew, $r, $ri) 
};

(: ******************************************************
   * Earley items:  extractors
   :)

(: See also sXei() below under Utilities :)

(: ......................................................
   pTo X Ei($E): extract 'to' position from item
   :)
declare function ixi:pToXEi(
  $E as map(xs:string, item())
) as xs:integer {
  $E('to')
};

(: ......................................................
   pFrom X Ei($E): extract 'from' position from item
   :)
declare function ixi:pFromXEi(
  $E as map(xs:string, item())
) as xs:integer {
  $E('from')
};

(: ......................................................
   r X Ei($E): extract rule from item
   :)
declare function ixi:rXEi(
  $E as map(xs:string, item())
) as element(rule) {
  $E('rule')
};

(: ......................................................
   nLhs X Ei($E): extract nonterminal on lhs of rule 
   from item
   :)
declare function ixi:nLhsXEi(
  $E as map(xs:string, item())
) as element(nonterminal) {
  element nonterminal {
    attribute name { $E('rule')/@name }
  }
};
 (: ......................................................
   lsymExpected X Ei($E): extract list of expected 
   symbols from item
   :)
declare function ixi:lsymExpectedXEi(
  $E as map(xs:string, item())
) as element()* {
  (: results will be element() or element(nonterminal). :)
  let $symCur := $E('ri'),
      $r := $E('rule'),
      $sFollowset := if ($symCur = 'q0') 
                     then $r/@first
                     else $r/@follow:*[local-name()=$symCur],
      $lsymFollow := tokenize($sFollowset,'\s+')[normalize-space(.)]
  for $sym in $lsymFollow
  let $e := $r//*[@xml:id = $sym]
  return $e
};
(: ******************************************************
   * Earley items:  predicates
   :)
(: ......................................................
   fFinal Ei P P N($E, $pFr, $pTo, $N): is $E a
   completion item for symbol N, running between the 
   two positions? (Used just once, in recognizeX, to 
   check for completions of the start symbol that cover 
   the entire input string.)
   :)
declare function ixi:fFinalEiPPN(
  $E as map(xs:string, item()),
  $pFrom as xs:integer,
  $pTo as xs:integer,
  $sym as xs:string
) as xs:boolean {
  (xs:integer($E('from')) eq $pFrom)
  and (xs:integer($E('to')) eq $pTo)
  and ($E('rule')/@name eq $sym)
  and ($E('ri') = ixi:lriFinalstatesXR($E('rule')))
};

(: ......................................................
   ixi:fFinalEiPN($E, $pTo, $sym):  true iff $E is a 
   completion item ending at position $P for nonterminal 
   $N 
   :)
declare function ixi:fFinalEiPN(
  $E as map(xs:string, item()),
  $pTo as xs:integer,
  $n as element(nonterminal)
) as xs:boolean {
  let $f := xs:integer($E('to')) eq $pTo
            and $E('rule')/@name eq $n/@name
            and $E('ri') = ixi:lriFinalstatesXR($E('rule'))
  (:
  let $trace := ixi:notrace($E,
        'Call to fFinalEiPN('
        || ixi:sXei($E) || ','
        || $pTo || ','
        || $n/@name || ') ==> ' 
        || $f
      )
  :)    
  (:
  let $trace := if ($f) then ()
        else ixi:notrace($E,
             'fFinalEiPN returns false: &#xA;'
                || ' to-values ' 
                  || (if (xs:integer($E('to')) eq $pTo)
		      then ''
		      else 'do not ' )
                  || 'match, &#xA;' 
                || ' symbol names '
                  || (if ($E('rule')/@name eq $n/@name)
                      then ''
		      else 'do not ' )
                  || 'match, &#xA;'
                || ' state ' || $E('ri')/string() || ' is ' 
                  || (if ($E('ri') = ixi:lriFinalstatesXR($E('rule'))) 
                        then '' else 'not ' )
                  || 'final. &#xA;' 
               )
  :)    
  return $f
};

(: ......................................................
   fFinal Ei($E): is $E a completion item?  I.e. is its 
   rule index in a final location?
   :)
declare function ixi:fFinalEi(
  $E as map(xs:string, item())
) as xs:boolean {
  $E('ri') = ixi:lriFinalstatesXR($E('rule'))
};
(: ......................................................
   fExpectsN - Ei($E):  does $E expect any nonterminals?
   :)
declare function ixi:fExpectsN-Ei(
  $E as map(xs:string, item())
) as xs:boolean {
  exists(ixi:lsymExpectedXEi($E)[ixi:fNonterminal(.)])
};
(: ......................................................
   fScanrel E E($E1, $E2):  does the scan relation hold 
   for E1, E2?
   (Used once, in Earley parser internals, to find 
   related items.)
   :)
   (: N.B. does not test that the symbol in question 
      is a terminal. Does it matter?
   :)   
declare function ixi:fScanrelEE(
  $E1 as map(xs:string, item()),
  $E2 as map(xs:string, item())
) as xs:boolean {
  let $fFrom := ($E1('from') eq $E2('from')),
        (: test 1 of advance() :)
      $lsymFollow := ixi:lsymExpectedXEi($E1), 
      $lSsymFollow := for $e in $lsymFollow return $e/@xml:id,
      $fStates1 := ($E2('ri') = $lSsymFollow),
        (: test 3, 4 of advance(), 1,2 of scan() :)
      $fRules := deep-equal($E1('rule'), $E2('rule')),
	(: test 2 of advance() :)
      $f := ($fFrom and $fStates1 and $fRules), 
      $trace := ($f,
                'fScanrelEE(' 
                || ixi:sXei($E1) || ',' 
                || ixi:sXei($E2) || ') ==> '
                )
  return $f
      (: 
               .('from') = $Ecur('from')
               and .('to') = $pMedial
               and .('ri') = $lsPrevstates
               and deep-equal(./rule, $Ecur/rule)
      :)
};

(: ......................................................
   fAdvanceNrel E E ($E1, $E2):  does the 
   advance-over-symbol-N relation hold for E1, E2?
   (Used once, in Earley parser internals, to find 
   related items.)

   By definition (see paper) E2 = advance(E1, T) iff
      * from(E1) = from(E2)
      * and rule(E1) = rule(E2)
      * and seen-so-far(E1) || T = seen-so-far(E2)
      * and E1 wins on T
      * else advance(E1, T) = empty set.

   Note that for the "E1 wins" clause we rely on the 
   truth of all items in the closure.  E1 must be  
   winning, because otherwise an E2 that satisfies 
   the other tests would not be in the closure.
   :)
declare function ixi:fAdvanceNrelEE(
  $E1 as map(xs:string, item()),
  $E2 as map(xs:string, item())
) as xs:boolean {
  let $fFrom := ($E1('from') eq $E2('from')),
      $lsymFollow := ixi:lsymExpectedXEi($E1),
      $lSsymFollow := for $e in $lsymFollow 
                      return $e/@xml:id,
      $fStates1 := ($E2('ri') = $lSsymFollow),
      $fRules := deep-equal($E1('rule'), $E2('rule')),
      $f := ($fFrom and $fStates1 and $fRules),
      $trace := ($f,
                'fScanrelEE(' 
                || ixi:sXei($E1) || ',' 
                || ixi:sXei($E2) || ') ==> '
                )
  return $f
      (: 
               .('from') = $Ecur('from')
               and .('to') = $eiCC('from')
               and .('ri') = $lsPrevstates 
               and deep-equal(./rule, $Ecur/rule)
      :)
};
(: *******************************************************
   * Earley items:  closure (the big kahuna)
   :)
 (: ......................................................
   ixi:earley-closure($lei, $I, $G2): 
   Calculate closure of $lei over the relations scan(), 
   pred(), and comp().
:)
declare function ixi:earley-closure(
  $leiPending as map(xs:string, item())* (: ITEM* :), 
  $I as xs:string,
  $G as element(ixml)
) as map(xs:string,
         map(xs:integer,
             map(xs:string,
                 item())*)) (:MEI:) {
  let $meiAcc := map { 
                   'from' : map:merge(
                     for $ei in $leiPending
		     return map:entry($ei('from'), $ei),
                     $ixi:combinedups
                   ),
                   'to' : map:merge(
                     for $ei in $leiPending
		     return map:entry($ei('to'), $ei),
                     $ixi:combinedups
		   ) }
		       
  return ixi:earley-closure($leiPending, $meiAcc, $I, $G)
};

(: ......................................................
   ixi:earley-closure($pending, $accumulator, $I, $G2):
:)
declare function ixi:earley-closure(
  $leiPending as map(xs:string, item())* (: pending items :),
  $meiAccum as map(xs:string, map(xs:integer, map(xs:string, item())*))
            (: accumulator of type MEI :),
  $I as xs:string,
  $G as element(ixml)
) as map(xs:string, map(xs:integer, map(xs:string, item())*)) (:MEI:) {
    if (empty($leiPending))
  then $meiAccum

  else 
  let $E := head($leiPending), 

      (: get everything from leiPCSrel :)
      $leiCs0 := ixi:leiPCSrel($E,$meiAccum,$I,$G),
                 
      
      (: dedup results from leiPCSrel :) 
      $leiCs := $leiCs0[
                   not(some $i in 1 to (position() - 1)
                       satisfies deep-equal(., $leiCs0[$i])
                   )],
        	
      (: remove non-new results from leiPCSrel :)
      $leiNew := for $ei in $leiCs
	         let $from := $ei('from')
		 where not(some $e in $meiAccum('from')($from)
		           satisfies deep-equal($e, $ei))
		 return $ei,

      
      $dummy := ixi:notrace(count($leiPending), 
                            'e-c() has pending items: '), 
      $dummy := ixi:notrace(
                    ixi:sXei($E),
                    'ixi:earley-closure running on item: '), 
      $dummy := ixi:notrace(count($leiCs0), 
                    'e-c() initial closure has items: '), 
      $dummy := ixi:notrace(count($leiCs), 
                     'e-c() deduped closure has items: '), 
      $dummy := ixi:notrace(count($leiNew), 
                     'e-c() New items: '), 

		 
      $meiNewaccum := map {
	'from' : map:merge(
	  ( $meiAccum('from'),
	  for $ei in $leiNew return map:entry($ei('from'), $ei) ),
	  $ixi:combinedups),
        'to' : map:merge(
	  ( $meiAccum('to'),
	  for $ei in $leiNew return map:entry($ei('to'), $ei) ),
	  $ixi:combinedups) }
      
  return ixi:earley-closure(
    (tail($leiPending), $leiNew),
    $meiNewaccum,
    $I,
    $G)
};

(: ......................................................
   leiPCSrel($E, $leiA, $I, $G): return all items $E2 
   such that 
   $E2 = scan($E, $I)
   or $E2 = pred($E, $G)
   or comp($E1, $E3) for some $E3 in $leiA
   or comp($E3, $E1) for some $E3 in $leiA
:)
declare function ixi:leiPCSrel(
  $E as map(xs:string, item()),
  $meiAccum as map(xs:string, item())*,
  $I as xs:string,
  $G as element(ixml)
) as map(xs:string, item())* {
  (: If $E expects terminals, perform scan :)
  
  ix:scan($E,$I),
  
  
  (: If $E expects nonterminals, perform prediction :)
  
  ix:pred($E,$G), 
  
  
  (: If $E expects a nonterminal, look for a 
     completion $Ec and perform comp($Ec,$E) :)
  
  if (ixi:fExpectsN-Ei($E))
  then for $Ec in $meiAccum('from')($E('to'))
       where ixi:fFinalEi($Ec)
       return ix:comp($Ec,$E)
  else (), 
  
    
  (: If $E is a completion, look for a prediction $Ep 
     and perform comp($E,$Ep) :)
  
  if (ixi:fFinalEi($E)) 
  then for $Ep in $meiAccum('to')($E('from'))
       where ixi:fExpectsN-Ei($Ep)
       return ix:comp($E,$Ep)
  else ()
  
    
  (: N.B. In BNF, $E can only expect one symbol, so 
     either scan or pred applies, but not both.  But 
     we are expecting EBNF and $E can predict several 
     things at the same time as being a completion. :)
};
   
(: ****************************************************** 
   * Grammars
   ****************************************************** :)
(: A grammar is an ixml element with no namespace. :)

 (: ******************************************************
   * Grammars: constructors
   :)
   
(: ......................................................
   augment-grammar($G):  given grammar, augment it as 
   Earley prescribes.
   :)
declare function ixi:augment-grammar(
  $G as element(ixml)
) as element(ixml) {
  let $symStart := ixi:symStartG($G),
      $symGoal := ixi:makeGoalsymbolG($G),
      $fNullable := ixi:fNullableNG($symStart, $G)
  return element ixml {
    element rule {
      attribute name {$symGoal}, 
      attribute xml:id {$symGoal || '_rule'},
      attribute nullable { false() },
      attribute first {$symStart || '_0'},
      attribute last {$symStart || '_0'},
      attribute { xs:QName('follow:'||$symStart||'_0') } 
                {()},        
      element alts {
        attribute xml:id {$symGoal || '_def_0'},
        attribute nullable { false() },
        attribute first {$symStart || '_0'},
        attribute last {$symStart || '_0'},
        attribute { xs:QName('follow:'||$symStart||'_0') } 
                  {()},
        element alt {
          attribute xml:id {$symGoal || '_alt_0'},
          attribute nullable { false() },
          attribute first {$symStart || '_0'},
          attribute last {$symStart || '_0'},
          element nonterminal {
            attribute name { $symStart },
            attribute xml:id {$symStart || '_0'},
            attribute nullable { false() },
            attribute first {$symStart || '_0'},
            attribute last {$symStart || '_0'}
          } (: end nonterminal :)
        } (: end alt :)
      } (: end def :)
    }, (: end rule :)
    $G/rule
  } (: end ixml :)
};
 (: ......................................................
   makeGoalsymbolG($G):  make a new goal symbol for 
   grammar G, ensuring that it's not the same as any 
   existing symbol.
   :)
declare function ixi:makeGoalsymbolG(
  $G as element(ixml)
) as xs:string {
  let $ln := distinct-values($G/rule/@name),
      $n := ('Goal', '_Goal_', '_G_o_a_l_', '_G-o-a-l_')
            [not(. = $ln)][1]
  return if (exists($n)) 
    then $n 
    else ixi:mungesymbol(ixi:symStartG($G), $ln)
};
(: ......................................................
   mungesymbol:  given a symbol, munge it (by adding _ 
   fore and aft) until it is no longer in the list of 
   symbols $ln (which is the symbols already in the 
   grammar).
   :)
declare function ixi:mungesymbol(
  $n as xs:string,
  $ln as xs:string*
) as xs:string {
  if ($n = $ln)
    then ixi:mungesymbol('_' || $n || '_', $ln)
    else $n
};


(: ******************************************************
   * Grammars: extractors
   :)
   
(: ......................................................
   symStart G():  return start symbol(s) of G
   :)
declare function ixi:symStartG(
  $G as element(ixml)
) as xs:string+ {
  $G/rule[1]/@name/normalize-space()
};

(: ******************************************************
   * Grammars:  predicates
   *
   * Note that predicates relating to symbols in context 
   * are here, not under symbol.  (Test:  is $G a 
   * parameter?)
   :)
(: ixi:fNullableNG($n, $G):  is nonterminal n nullable 
   in G? 

   For non-terminal N, fNullableNG(N,G) means an N 
   element in the result tree may be empty.

   Here 'nullable' means it has a right-hand side whose
   regex matches the empty string, which means in turn
   that the parse tree may be empty, and non-terminal N
   may appear as an N element in the result.
   
   N.B. this is not the same as fGES.
  
:)
declare function  ixi:fNullableNG(
  $n as xs:string, (: element(nonterminal), :)
  $G as element(ixml)
) as xs:boolean {
  exists($G/rule[@name = $n][@nullable = ('true', '1')])
};


(: ixi:fGesNG($n, $G):  does nonterminal n generate the 
   empty string in G? 
   
   N.B. this is not the same as fNullable.
   
   Discussions of parsing often use 'nullable' for 
   nonterminals that generate the empty string, but in 
   the grammar 
     S: X. X: .
   X is nullable and GES, S is GES but not nullable.
   
   For non-terminal N, fGesNG(N,G) means an N element
   in the result tree may have string(N) = ''.
   
:)
(: this is a transitive closure algorithm and will 
   require more work (including an accumulator to 
   avoid looping).
   
   For now, suppress it and do without it.
:)
(:
declare function  ixi:fGesNG(
  $n as element(), 
  $G as element(ixml)
) as xs:boolean {
  ($n/self::nonterminal 
     and ixi:fNullable($n, $G)
         or 
         (some $d 
          in $G/rule[@name=$n]/alt
          satisfies ixi:fGesNG($d,$G)))
  or ($n/self::def
     and ($n/@nullable = ('true','1'))
  or 
  ()
 
};
:)

(: ixi:lrulesXNG($n,$G) :)
declare function ixi:lrulesXNG(
  $n as element(nonterminal),
  $G as element(ixml)
) as element(rule)* {
  $G/rule[@name = $n/@name]
};


(: ******************************************************
   * Grammars: predicates
   :)


   
(: ****************************************************** 
   * Rules and rule indexes
   ****************************************************** :)
(: A rule is a rule element as defined in the ixml DTD, but 
   augmented with glushkov attributes.
   
   Note that functions relating to rules in context are 
   not here but under Grammars above.  (Test: is $G a 
   parameter?) Functions here relate solely to the rule 
   in isolation. That may be why there are so few of them.
:)

(: ******************************************************
   * Rules and rule indexes: constructors
   :)
   
(: ******************************************************
   * Rules and rule indexes: extractors
   :)

(: ixi:lriFinalstatesXR($r) :)
declare function ixi:lriFinalstatesXR(
  $r as element(rule)
) as xs:string* {
  (
    if ($r/@nullable = ('true', '1'))
    then 'q0' else (),
    tokenize($r/@last,'\s+')[normalize-space()]
  )

};

(: ixi:lriStartstatesXR($Rule):  return list of 
   start-position identifiers.
 :)
declare function ixi:lriStartstatesXR(
  $r as element(rule)
) as xs:string* {
  'q0'
  (: NOT 
  tokenize($r/@first,'\s+')[normalize-space()]
  :)
};

(: duplicate, apparently :)
(:
declare function ixi:initial-stateR(
  $Rule as element(rule)
) as xs:string* {
  'q0'
  (: NOT
  tokenize($Rule/@first,'\s+')[. ne '']
  Those are the follow states of q0.  Whoops.
  :)
};
:)

(: ******************************************************
   * Rules and rule indexes: predicates
   :)
   
(: ****************************************************** 
   * Symbols
   ****************************************************** :)

(: ******************************************************
   * Symbols: constructors
   :)
   
(: ******************************************************
   * Symbols: extractors
   :)
(: ......................................................
   match-length($t):  return length of any string that 
   matches the specified terminal.  
   :)
declare function ixi:match-length(
  $t as element()
) as xs:integer {
  if ($t/self::literal) then ixi:string-length($t)
  else 1
};

(: ......................................................
   re X Terminal($t): return a regular expression, given 
   a character-set terminal element.
   :)
declare function ixi:reXTerminal(
  $t as element() (: incl, excl, literal :)
) as xs:string {
  (: given a terminal element, produce a regex :)
  if ($t/self::literal) then
    ixi:sceXS( ixi:string-value($t) )
  else 
  let $le := $t/*,
      $lsRegexbits := for $e in $le
                      return if ($e/self::range)
                        then ixi:sceXS($e/@from)
		             || "-" || ixi:sceXS($e/@to)
                        else if ($e/self::literal) 
                        then ixi:sceXS($e/ixi:string-value($e)) 
                        else if ($e/self::class)
                        then ixi:catescXS($e/@code) 
                        else () (: error :)
  return if ($t/self::inclusion)
    then "[" || string-join($lsRegexbits,'') || "]"
    else if ($t/self::exclusion)
    then "[^" || string-join($lsRegexbits,'') || "]"
    else "--error in reXTerminal--"
};

 
(: ******************************************************
   * Symbols: predicates
   :)
(: ......................................................
   f Terminal($sym):  is $sym a terminal symbol?
   :)
declare function ixi:fTerminal(
  $sym as item()
) as xs:boolean {
  exists($sym/self::element()[self::terminal
    or self::literal
    or self::inclusion
    or self::exclusion
  ])
};

(: ......................................................
   f Nonterminal($sym):  is $sym a nonterminal symbol?
   :)
declare function ixi:fNonterminal(
  $sym as item()
) as xs:boolean {
  exists($sym/self::element()/self::nonterminal)
};

(: ......................................................
   fSymbolmatch R Ri Sym($r, $ri, $sym): does symbol 
   element $sym match rule index $ri in rule $r?  
   
   :)
declare function ixi:fSymbolmatchRRiSym(
  $r as element(rule),
  $ri as xs:string,
  $sym as element() (: nonterminal or terminal :)
) as xs:boolean {  
  if ($sym/@xml:id = $ri)
  then true()
  else let $state := $r/descendant::*[@xml:id = $ri]
       return if (local-name($sym) ne local-name($state))
           (: we have a terminal trying to match a nonterminal,
              or vice versa, or different kinds of terminal;
              return false :)
         then false()
         
         else if (ixi:fTerminal($sym))
           (: we have terminals; they match if their children 
              are deep-equal.  NB we are relying on the fact
              that we have just extracted the terminal element
              from the rule we are working on, so it really
              ought to be deep-equal to itself.
              :)
         then deep-equal($state, $sym)
         (: was: 
         then deep-equal($state/*, $sym/*) 
         but when the terminal element is empty, that doesn't work.
         :)
         
         else if (ixi:fNonterminal($sym))
           (: we have non-terminals, they match on name :)
         then ($sym/@name eq $state/@name) 
         
         else (: something wrong :) false()
};

   

(: ****************************************************** 
   * Input
   ****************************************************** :)
(: For now, the input is always a string. :)

(: ******************************************************
   * Input: constructors
   :)

(: ******************************************************
   * Input: extractors
   :)
(: ......................................................
   inputlength(): how long is the input?
   
   Used (once) for construction of an Earley item 
   signaling completion
   :)
declare function ixi:inputlength(
  $I as xs:string
) as xs:integer {
  string-length($I)
};

(: ******************************************************
   * Input: predicates
   :)

(: ......................................................
   cMatches I P T($I, $P, $T): does input $I match 
   terminal $T at position $P?  For how many characters?
   
   Note that position is 0-based, not 1-based, so we add 1 to it
   for XQuery substring calls.
   :)
declare function ixi:cMatchesIPT( 
  $I as xs:string, 
  $p as xs:integer,
  $t as element()
) as xs:integer {
  if ($t/self::literal) then
     let $sProbe := ixi:string-value($t),
         $cPrLen := string-length($sProbe),
         $sInseg := substring($I,$p+1,$cPrLen),
         $fYesno := ($sProbe eq $sInseg)
     return if ($fYesno) 
            then $cPrLen 
            else -1
  else if ($t/self::inclusion or $t/self::exclusion) then
     let $sProbe := ixi:notrace(ixi:reXTerminal($t), 
                              'regex for char set:'), 
         $sInseg := ixi:notrace(substring($I,$p+1,1), 
                              'substring (1 char):'),
         $fYesno := ixi:notrace(matches($sInseg,'^'||$sProbe||'$'),
	                      'matches?')
     return if ($fYesno)
            then 1
            else -1
  else (: error :) -1
};
   
(: ****************************************************** 
   * Utilities
   ****************************************************** :)
(: Things with no other obvious home. :)

(: ******************************************************
   * Utilities: string to regex conversion, 
   * string-length, string-value, ...
   :)
(: ......................................................
   sce X S($s) : given a one-character string or hex
   expression $s (e.g. from a character terminal), check
   to see if it's a hex expression (in which case expand
   and recur) or a magic character (in which case escape
   it) or is best represented for purposes of regex
   mapping) with a single-character escape (in which
   case escape it).
   
   N.B. this is more than strictly necessary for
   character class escapes, but it seems better to be
   more general.

   To do: adjust to new representation of terminals.
   
:)
declare function ixi:sceXS(
  $s as xs:string
) as xs:string {
  (: reEscapists:  regex matching characters 
     which must or may be escaped. :)  
  if (matches($s,'^#[0-9a-fA-F]+$'))
  then ixi:sceXS(ixi:charXhex(
    $s
    (: ixi:notrace($s,'sceXS calling charXhex on ' || $s)) :)
  ))
  else if (string-length($s) gt 1)
  then ixi:escapedstringXS($s) 
  else if (not(contains("&#xA;&#xD;&#x9;\|.-^?$*+{}()[]",$s))) 
  then $s
  else if (contains("\|.-^?$*+{}()[]",$s)) 
  then concat("\" (:":), $s)   (: commented dq helps emacs :) 
  else if ($s eq '&#xA;')
  then "\n"
  else if ($s eq '&#xD;')
  then "\r"
  else if ($s eq '&#x9;')
  then "\t"
  else $s

};

declare function ixi:escapedstringXS(
  $s as xs:string
) as xs:string {
  let $reEscapists := concat('[',
                      '&#xA;&#xD;&#x9;', 
                      '\\\|\.\-\^\?\$\*\+',
		      '\{\}\(\)\[\]',
                      ']') 
  return if (matches($s, $reEscapists))
  then string-join(
    for $i in 1 to string-length($s)
    return ixi:sceXS(substring($s, $i, 1)),
    '')
  else $s
};

(: ......................................................
   catesc X S($s): given a one- or two-character string
   from a class element, return the appropriate category
   escape in XSD/XPath notation.

   I should do some sanity checking here, but at the
   moment I'm impatient, so I just wrap it in braces
   with \p in front.

   The 2019 spec says "it is an error if there is no
   such class", so probably I should raise an error if
   the category given does not match the list.  But for
   now, I'll just ignore it and return '.'  to match one
   character, on the theory of "carry on irregardless."

   To do:  figure out how Aparecium should handle errors.
:)
declare function ixi:catescXS(
  $s as xs:string
) as xs:string {
  if (matches($s,'^(L[ulmo]?'
     || '|M[nce]?'
     || '|N[dlo]?'
     || '|P[cdseifo]?'
     || '|Z[slp]?'
     || '|S[mcko]?'
     || '|C[cfon]?)$'))
  then '\p{' || $s || '}'
  else '.'
  (: Letters: u[pper] l[ower] t[itlecase] m[odifier] o[other]
     Marks: n[onspacing], [spacing ]c[ombining], e[nclosing]
     Numbers: d[ecimal digit] l[etter] o[ther]
     Punctuation: c[onnector] d[ash] s [= open]
         e [= close] i[nitial quote] f[inal quote] o[ther]
     Z separators: s[pace] l[ine] p[aragraph]
     Symbols: m[ath] c[urrency] k[=modifier] o[ther]
     C other: c[ontrol] f[ormat] o[=private  use] n[ot assigned]
  :)
};
(: ......................................................
   char X hex ($s): accept a hex expression, return the
   character.
:)
declare function ixi:charXhex(
  $s0 as xs:string
) as xs:string {
  (: let $tracing := ixi:notrace($s0,
     'charXhex called with |' || $s0 || '|') :)
  let $s := if (starts-with($s0,'#'))
            then substring($s0,2)
            else $s0
  return if (not(matches($s, '^[0-9a-fA-F]+$')))
         then '---error in charXhex---'
         else codepoints-to-string(d2x:x2d($s))
};
(: ......................................................
   string-length:  calculate 'real' length of string.

   We use this to hide possible variation in the form of
   'quoted' strings.  (Q. Does that mean we are
   expecting quote doubling to show up in the XML form
   of the literal?  It shouldn't.)

   To do: sanity check this, and delete if unnecessary.
   :)
declare function ixi:string-length(
  $q as element(literal)
) as xs:integer {
  string-length(ixi:string-value($q))
};
(: ......................................................
   string-value:  calculate 'real' value of string.

   We use this to hide possible variation in the form of
   quoted strings.  (Q. Does that mean we are expecting
   quote doubling to show up in the XML form of the
   literal?  It shouldn't.)

   To do:  sanity check this, and delete if unnecessary.
   :)
declare function ixi:string-value(
  $q as element(literal)
) as xs:string {
  let $s := if ($q/@string)
            then string($q/@string)
            else if ($q/@dstring)
            then replace($q/@dstring,'""','"') (:":)
            else if ($q/@sstring) 
            then replace($q/@sstring,"''", "'") 
            else if ($q/@hex) 
            then ixi:charXhex($q/@hex)
            else string($q)
  return if (matches($s,'^#[0-9a-fA-F]+$'))
         then ixi:charXhex(
               ixi:notrace($s,'string-value calls cXh on ' || $s) 
             )
         else $s
};
(: ......................................................
   s X ei($E): a utility function to help make traces
   more legible.
   :)
declare function ixi:sXei(
  $E as map(xs:string, item())
) as xs:string {
  'item('
  || $E('from') || ' ' 
  || $E('to') || ' '
  || $E('rule')/@name || '/' || $E('ri')
  || ')'
};
(: ......................................................
   e X ei($E):  a utility function to help make traces 
   and dumps more legible.
   :)
declare function ixi:eXei(
  $E as map(xs:string, item())
) as element(item) {
  element item {
    attribute from { $E('from') },
    attribute to { $E('to') },
    attribute rulemark { $E('rule')/@mark },
    attribute rulename { $E('rule')/@name },
    attribute ri { $E('ri') }
    }
};
(: ......................................................
   trace($i, $s):  a utility function to help make code 
   being traced stay more legible.
   :)
declare function ixi:trace(
  $x as item()?,
  $s as xs:string
) as item()? {
  trace($x, '&#xA;' || $s || '&#xA;')
};

(: ......................................................
   notrace($i, $s):  a utility function to help make 
   code being traced stay more legible.
   :)
declare function ixi:notrace(
  $x as item()?,
  $s as xs:string
) as item()? {
  $x 
}; 

   
