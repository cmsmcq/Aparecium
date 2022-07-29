module namespace ix =
"http://blackmesatech.com/2019/iXML/Earley-recognizer";

(: Earley parser, v0 :)

import module namespace ixi =
"http://blackmesatech.com/2019/iXML/Earley-rec-internals"
at "Earley-rec-internals.xqm";

(: ****************************************************** 
   * ix:scan($E, $I)
   ****************************************************** :)
(: If $E expects any terminals which occur as expected, 
   return the advance of E over those terminals.  There 
   may be more than one. :)
   
declare function ix:scan(
  $E as item() (: ITEM :),
  $I as item() (: INPUT :)
) as item()* (: ITEM? :) {
  let $p := ixi:pToXEi($E),
      $lt := ixi:lsymExpectedXEi($E)[ixi:fTerminal(.)]
  for $t in $lt
  return
    let $c := ixi:cMatchesIPT($I, $p, $t)
    return 
    if ($c ge 0)
    then (ixi:leiAdvanceEiSymP($E, $t, $p + $c),
         ixi:eiMakePPT($p, $p + $c, $t))
    else ()
};


(: ****************************************************** 
   * ix:pred($E, $G)
   ****************************************************** :)
(: If $E predicts any non-terminals, return items which 
   expect those non-terminals at the appropriate location. 
   :)
   
declare function ix:pred(
  $E as item() (: ITEM :),
  $G as item() (: GRAMMAR :)
) as item()* (: ITEM :) {
  (: iterate over
       $ln nonterminals expected by $E,
       $lr rules in $G for $n,
       $lri initial positions in $r
     also return advance of $E for nullable $n
   :)
   let $p := ixi:pToXEi($E),
       $ln := ixi:lsymExpectedXEi($E)[ixi:fNonterminal(.)]
   for $n in $ln
   let $fNullable := ixi:fNullableNG($n/@name, $G),
       $lr := ixi:lrulesXNG($n,$G)
   return (
     (: first, return advance of $E if $n nullable :)
     if ($fNullable)
     then ixi:leiAdvanceEiSymP($E,$n,$p)
     else (),
       
     (: then iterate over rules and initial locations for $n :)
     for $r in $lr
     let $lri := ixi:lriStartstatesXR($r)
     for $ri in $lri
     return ixi:eiMakePPRRi($p, $p, $r, $ri)
   )
};

(: ****************************************************** 
   * ix:comp($Ec, $Ep)
   ****************************************************** :)
(: If $Ec and $Ep are a prediction/completion pair, return
   the advance of $Ep over the non-terminal predicted by 
   $Ec. :)
   
(: comp($Ec, $Ep): if $Ec is a completion item, 
   and $Ep a prediction item,
   and $Ep predicts a nonterminal $n at position $pPTo,
   and $Ec completes $n starting at $pCFrom=$pPTo,
   then advance $Ep over $n and place the new to-position
   at the to-position of $Ec.
   
   The test for whether $Ep expects $n is handled
   by leiAdvanceEiSymP, so we need not make it here.
:)
declare function ix:comp(
  $Ec as item() (: ITEM :),
  $Ep as item() (: ITEM :)
) as item()* (: ITEM :) {
  let $pCFrom := ixi:pFromXEi($Ec),
      $pCTo   := ixi:pToXEi($Ec),
      (: $pPFrom := ixi:pFromXEi($Ep), :)
      $pPTo   := ixi:pToXEi($Ep),
      $n      := ixi:nLhsXEi($Ec),
      $RESULT := if (ixi:fFinalEi($Ec)
                    and $pPTo eq $pCFrom)
                 then ixi:leiAdvanceEiSymP($Ep, $n, $pCTo)
                 else ()
  return $RESULT
};


declare function ix:recognize(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :),
  $options as map(*)
) as xs:boolean {
  let $m := ix:recognizeX($I, $G, $options)
  return $m('Result')
};

declare function ix:recognizeX(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :),
  $options as map(*)
) as map(*) {
  let $G2 := ixi:augment-grammar($G),
      $symStart0 := ixi:symStartG($G),
      $symStart2 := ixi:symStartG($G2),
      $rInitial := ixi:lrulesXNG(
        <nonterminal name="{$symStart2}"/>, 
        $G2)[1],
      $riInitial := ixi:lriStartstatesXR($rInitial)[1],
      $eiInitial := ixi:eiMakePPRRi(0, 0, 
                                    $rInitial, 
                                    $riInitial),
      $len := ixi:inputlength($I),
      
      $meiClosure := 
          ixi:earley-closure($eiInitial, $I, $G2),
      (: $leiCompletions := $meiClosure
         [ixi:fFinalEiPPN(.,0,$len,$symStart2)], :)
      $leiCompletions := $meiClosure('from')(0)
                         [ixi:fFinalEiPPN(., 0,
                                          $len,
                                          $symStart2)],
      $result := exists($leiCompletions)

  return map {
    'Grammar' : $G2,
    'Initial-Item' : $eiInitial,
    'Input' : $I,
    'Input-Length' : $len,
    'Closure' : $meiClosure,
    'Completions' : $leiCompletions,
    'Result' : $result
  }
};

