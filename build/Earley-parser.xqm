module namespace ep =
"http://blackmesatech.com/2019/iXML/Earley-parser";

(: The top-level definition of an Earley parser. :)

import module namespace epi =
"http://blackmesatech.com/2019/iXML/Earley-parser-internals"
at "Earley-parser-internals.xqm";
  

(: Goal:  to return the set of parse trees recorded implicitly in the
   Earley closure.
   :)
(: ep:alltrees($I,$G):  return all loopless parse trees :)
declare function ep:all-trees(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()+ {
  (: trace((), 'ep:all-trees calling epi:earley-parse'), :)

  epi:earley-parse($I, $G, epi:all-trees#3)
  
  (: trace((), 'epi:earley-parse has returned '
        || 'and ep:all-trees is about to do so.') :)
};

(: ep:anytree($I,$G):  return one (loopless) parse tree, 
   whichever is found first 
:)
declare function ep:any-tree(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()? {
  epi:earley-parse($I, $G, epi:any-tree#3)
};

(: ep:tree-cursor($I,$G):  return pair consisting of 
   1 a parse tree, and
   2 a function to return the next parsetree/function pair, or
     when trees are exhausted to return a 'no-more-trees' signal.
     
   The name is intended to recall the cursor notion of SQL results.
   
   If you keep track of the number of trees delivered, the
   no-more-trees signal can distinguish there-were-no-trees
   from all-done-now signals.
:)
declare function ep:tree-cursor(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as item()* {
  epi:earley-parse($I, $G, epi:tree-cursor#3)
};

(: ep:parseforestmap($I,$G):  return a map containing an and/or tree
   representing the set of all parses.
:)
declare function ep:parse-forest-map(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()* {
  epi:earley-parse($I, $G, epi:parse-forest-map#3)
};

(: ep:parseforestgrammar($I,$G):  return a BNF (not EBNF[?]) grammar
   describing the set of all parses of $I against $G.
:)
declare function ep:parse-forest-grammar(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()* {
  epi:earley-parse($I, $G, epi:parse-forest-grammar#3)
};

(:



:)
(: Given a final item, build a tree for it.
:)