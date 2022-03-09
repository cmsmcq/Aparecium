module namespace ep =
"http://blackmesatech.com/2019/iXML/Earley-parser";

(: The top-level definition of an Earley parser. :)

import module namespace epi =
"http://blackmesatech.com/2019/iXML/Earley-parser-internals"
at "Earley-parser-internals.xqm";
  

(: Goal:  to return the set of parse trees recorded implicitly in the
   Earley closure.
   :)
(: ep:all-trees($I,$G):  return all loopless parse trees :)
declare function ep:all-trees(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()+ {

  epi:earley-parse($I, $G, 
      map { 'return': 'all-trees',
            'tree-count': -1,
            'failure-dump': 'closure'
      }
  )
  
};


(: ep:any-tree($I,$G):  return one (loopless) parse tree, 
   whichever is found first 
:)
declare function ep:any-tree(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()? {
  epi:earley-parse($I, $G, 
      map { 'return': 'any-tree',
            'tree-count': 1,
            'ambiguity-test': true(),
            'failure-dump': 'closure',
            'tree-constructor': 'pfg'
      }
  )
};


declare function ep:tree-cursor(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as item()* {
  epi:earley-parse($I, $G,  
      map { 'return': 'tree-cursor',
            'failure-dump': 'closure' }
  )
};


(: ep:parse-forest-map($I,$G):  return a map containing an and/or tree
   representing the set of all parses.
:)
declare function ep:parse-forest-map(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()* {
  epi:earley-parse($I, $G, 
      map { 'return': 'parse-forest-map', 
            'tree-count': -1,
            'failure-dump': 'closure'
      }
  )
};

(: ep:parse-forest-grammar($I,$G):  return a BNF (not EBNF[?]) grammar
   describing the set of all parses of $I against $G.
:)
declare function ep:parse-forest-grammar(
  $I as item() (: INPUT :),
  $G as item() (: GRAMMAR :)
) as element()* {
  epi:earley-parse($I, $G, 
      map { 'return': 'parse-forest-grammar',
            'tree-count': -1,
            'failure-dump': 'closure'
      }
  )
};

