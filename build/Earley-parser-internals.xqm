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

(: We rely on the EXPath file module, and we use maps. :)
declare namespace file =
"http://expath.org/ns/file";

declare namespace map =
"http://www.w3.org/2005/xpath-functions/map";



(: ****************************************************************
   earley-parse($I, $G, $f);  run Earley recognizer on 
   input $I and grammar $G, return results using 
   $f($leiClosure, $Ec, $I, $G)
:)
declare function epi:earley-parse(
  $I as xs:string,
  $G as element(ixml),
  $f as function(
    map(*)*  (: Ec :),
    map(*)* (: Closure :),
    xs:string (: Input :)
    (: , element(ixml) (: Grammar :) :)
  ) as item()* 
) as item()* {
  let $dummy := eri:trace((), 'epi:earley-parse() ...') 
  let $mapResult := er:recognizeX($I, $G), 
      $meiClosure := $mapResult('Closure'),
      $leiCompletions := $mapResult('Completions')
  return if ($mapResult('Result'))
    then (: if we have a result, return each parse tree :)
        let $dummy := eri:trace((), 'epi:earley-parse() has result') 
        let $lpt := $f($leiCompletions, $meiClosure, $I (: , $G :) )
        for $pt at $npt in $lpt
        let $dummy := eri:trace((), 'epi:earley-parse() returning a result') 
        (: return if (('raw','ast')[2] eq 'raw') 
	       then $pt  
               else epi:astXparsetree($pt, count($lpt)) :)
        (: What an ugly hack!  Clean this up! :)
        let $logfn := '/Users/cmsmcq/'
                      || '2021/Aparecium/tests/output/raw.'
	              || translate(
                           string(
                             adjust-dateTime-to-timezone(
                               current-dateTime(), 
                               ())),
                           ' :',
                           '__')
                      || $npt
                      || '.xml'   
        return (file:write($logfn, $pt), 
                epi:astXparsetree($pt, count($lpt)))
        
   else (: otherwise, send an apology and explanation :)
   <no-parse>
   <p>Sorry, no parse for this string and grammar.</p>
   <p>The completions are:</p>
   <completions>{$leiCompletions}</completions>
   <p>The map is:</p>
   
   <Initial-Item>{eri:eXei($mapResult('Initial-Item'))}</Initial-Item>
   <Input>{$mapResult('Input')}</Input>
   <Input-Length>{$mapResult('Input-Length')}</Input-Length>
   <Completions>{
     for $ei in $mapResult('Completions')
     return eri:eXei($ei)
   }</Completions>
   <Closure>{
     let $mei := $mapResult('Closure')
     for $n in map:keys($mei('to'))
     order by $n descending
     for $ei in $mei('to')($n)
     return eri:eXei($ei)
   }</Closure>
   <Result>{$mapResult('Result')}</Result>
   <grammar>{(: 'Omitted.' :) $mapResult('Grammar') }</grammar>
   </no-parse>
   (: we have to think about how to return that no-parse signal.
   :)
};

(: ****************************************************************
   all-trees($Closure, $Ec, $I, $G):  
:)
declare function epi:all-trees(
  $leiCompletions as map(*)*,
  $meiClosure as map(xs:string,
                     map(xs:integer,
                         map(xs:string, item())*)) (:MEI:),
  $I as xs:string
  (: $G as element(ixml) :)
) as element()* {
  (: Call auxiliary routine with a vertical stack for
     loop prevention. :)
  epi:all-trees($leiCompletions, $meiClosure, $I, ())
};
(: ****************************************************************
   all-trees#5:  auxiliary function (more args, does the work) 
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
  $leiClosure as map(*)*,
  $I as xs:string
) as element() {
  <parse-forest-grammar-not-implemented-yet/>
};

(: ****************************************************************
   epi:all-node-sequences($item, $closure, $acc, $from, $to, $I)
:)
declare function epi:all-node-sequences(
  $Ecur as map(*),
  $meiClosure as map(xs:string, map(xs:integer, map(xs:string, item())*)),
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
      element error {
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
      let $dummy := eri:trace(
          concat(name($c), '/', $c/@name, '/', $c/@xml:id),
          'constructing content from:') 
      let $n := epi:contentXpt($c)
      let $dummy := for $chunk in $n return
          if ($chunk instance of text())
          then eri:trace(concat('/',
	  string-join(string-to-codepoints($chunk),' '), '/'), 'eXpt got text node') 
          else if ($chunk instance of element())
	  then eri:trace($chunk/name(), 'eXpt gets element:') 
	  else eri:trace($chunk, 'eXpt gets unknown item:') 
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


