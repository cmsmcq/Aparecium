module namespace gl =
"http://blackmesatech.com/2019/iXML/Gluschkov";

(: Constructs a Gluschkov automaton for ixml :)

(: GPL ...:) 

declare namespace follow =
"http://blackmesatech.com/2016/nss/ixml-gluschkov-automata-followset";

import module namespace d2x =
'http://blackmesatech.com/2019/iXML/d2x'
at "d2x.xqm";

declare variable $gl:follow-ns :=
"http://blackmesatech.com/2016/nss/ixml-gluschkov-automata-followset";

declare function gl:ME (
  $E as element()
) as element() {
  let $children := for $c in $E/node() 
                   return if ($c/self::element())
                          then gl:ME($c)
                          else $c,
      $ch := $children[self::element()]
  return if ($E/self::range)
then 
   element { name($E) } {
      $E/@*, 
      attribute regex {
         '['
         || gl:read-one-char-spec(string($E/@from))
	 || '-'
         || gl:read-one-char-spec(string($E/@to))
	 || ']'	 
      },
      $E/child::node()
   }
else if ($E/self::class)
then 
   element { name($E) } {
      $E/@*, 
      attribute regex { '\p{' || $E/@code || '}'}
   }

  else if ($E/self::inclusion or $E/self::exclusion
    or $E/self::literal)
then
      let $id := '_t_' 
                 || (1 + count(($E/preceding::* | $E/ancestor::*)
                    [self::inclusion 
                    or self::exclusion
		    or self::literal])), 
          $re := 'dummy' (:if ($E/self::inclusion) 
                 then gl:inclusion-regex($E) 
                 else if ($E/self::exclusion)
                 then gl:exclusion-regex($E) 
                 else if ($E/self::literal)
		 then gl:literal-regex($E)
		 else '[! error in gl:ME !]'
		 :)
      return element {name($E)} {
         $E/@*,
         attribute xml:id { $id },
         attribute nullable { false() },
         attribute first { $id },
         attribute last { $id },
         attribute {QName($gl:follow-ns, "follow:" || $id)} { },
	 attribute regex { $re },
         $children
      }
  else if ($E/self::nonterminal)
then
     let $id := $E/@name || '_'
                || (1 + count($E/preceding::nonterminal
                              [@name = $E/@name]))
     return element nonterminal {
       $E/@*,
       attribute xml:id { $id },
       attribute nullable { false() },
       attribute first { $id },
       attribute last { $id },
       attribute {QName($gl:follow-ns, "follow:" || $id)} { },
       $children
     }
  else if ($E/self::option
    [count(*) eq 1]
    [child::*[self::inclusion
              or self::exclusion
              or self::literal 
              or self::nonterminal 
	      or self::alts]])
then
     let $id := 'exp_option_' || (1 + count($E/preceding::option))
     return element option {
       $E/@*,
       attribute xml:id { $id },
       attribute nullable { true() },
       attribute first { $children/@first },
       attribute last { $children/@last },
       for $follow-att in $children/@follow:* 
       return $follow-att,
       $children
     }
  else if ($E[self::repeat0 or self::repeat1]
      [*[1]
        [self::inclusion or self::exclusion
        or self::literal
        or self::nonterminal
	or self::alts]]
      [count(*) eq 1 
      or child::*[2][self::sep]]) 
then let $gi := name($E)
     let $id := 'exp_' || $gi || '_' 
                || (1 + count($E/preceding::*[name() = $gi])),
         $F := gl:notrace($ch[1], "F: "),
         $G := gl:notrace($ch[2], "G: ")
     return element {$gi} {
       $E/@*,
       attribute xml:id { $id },
       attribute nullable { 
         if ($gi = 'repeat0') 
         then true() 
         else $F/@nullable
       },
       attribute first { 
         if (xs:boolean($F/@nullable) = true())
         then concat($F/@first, ' ', $G/@first)
         else $F/@first
       },
       attribute last { 
         if (xs:boolean($F/@nullable) = true())
         then concat($F/@last, ' ', $G/@last)
         else $F/@last
       },
              if (count($ch) eq 1)
       then
         let $lastF := tokenize($F/@last,'\s+'),
             $firstF := tokenize($F/@first,'\s+')
         for $a in $F/@follow:*
         return if (local-name($a) = $lastF)
           then attribute { 
               QName($gl:follow-ns, "follow:"||local-name($a) ) 
             } { 
               gl:merge((tokenize($a,'\s+'), $firstF))    
             }
           else $a
       else (: count($children) eq 2 :)
         let $lastF := tokenize($F/@last,'\s+'),
             $lastG := tokenize($G/@last,'\s+'),
             $firstF := tokenize($F/@first,'\s+'),
             $firstG := tokenize($G/@first,'\s+'),
             $nullableF := (xs:boolean($F/@nullable) = true()), 
             $nullableG := (xs:boolean($G/@nullable) = true())
         return 
           for $a in $children/@follow:* 
           let $p := local-name($a),
               $follow0 := tokenize($a,'\s+')
           let $followset :=  
                          if ($p = $lastF and $nullableG) 
             then gl:merge(($follow0, $firstG, $firstF))

                          else if ($p = $lastF and not($nullableG))
             then gl:merge(($follow0, $firstG))

                          else if ($p = $lastG and $nullableF)
             then gl:merge(($follow0, $firstG, $firstF))

                          else if ($p = $lastG and not($nullableF))
             then gl:merge(($follow0, $firstF))

                          else string($a)

           return attribute { 
                    QName($gl:follow-ns, 
                          "follow:"||local-name($a) ) 
                } { 
                    $followset    
                    }
       ,         
       $children
     }
   
  else if ($E/self::sep
           [count(*) eq 1]
           [child::*[self::inclusion
                     or self::exclusion 
                     or self::literal 
                     or self::nonterminal 
                     or self::alts]]
          ) then
     let $id := 'exp_sep_'
                || (1 + count($E/preceding::sep)) 
     return element sep {
       $E/@*,
       attribute xml:id { $id },
       $ch/@nullable,
       $ch/@first,
       $ch/@last,
       $ch/@follow:*,
       $children
     }
     
  else if ($E/self::alt) then
     let $id := 'exp_alt_'
                || (1 + count($E/preceding::alt)) 
     return element alt {
       $E/@*,
       attribute xml:id { $id },
       attribute nullable { 
         every $c in $ch
         satisfies (xs:boolean($c/@nullable) eq true())
       },
       attribute first { 
         string-join(
           for $c at $pos in $ch
           return if (every $lsib
	              in $ch[position() lt $pos]
                      satisfies
		      (xs:boolean($lsib/@nullable)
		      eq true() ))
                  then $c/@first
                  else (),
           ' '
         )
       },
       attribute last { 
         string-join(
           for $c at $pos in $ch
           return if (every $rsib
	              in $ch[position() gt $pos]
                      satisfies
		      (xs:boolean($rsib/@nullable)
		      eq true() ))
                  then $c/@last
                  else (),
           ' '
         )
       },
              for $c at $cpos in $ch 
       for $a in $c/@follow:*
       let $p := local-name($a),
           $lastC := tokenize($c/@last,'\s+'),
           $rightsibs := $ch[position() gt $cpos],
           $followset := if ($p = $lastC)
	   then string-join(
             (  $a,
                for $rsib at $rpos in $rightsibs
                let $inbetweens := $rightsibs
		                   [position() lt $rpos]
                return if (every $msib in $inbetweens
                           satisfies
                           (xs:boolean($msib/@nullable)
			   = true() ))
                       then $rsib/@first
                       else ()
             ),
             ' '
           )
           else
             $a
       return attribute { 
             QName($gl:follow-ns, "follow:"||$p )
         } { 
             $followset    
         }

       ,
       $children
     }

  else if ($E[self::alts]) then
     let $id := 'exp_' || name($E) || '_' 
                || (1 + count(
                $E/preceding::alts)
		) 
          return element {name($E)} {
       $E/@*,
       attribute xml:id { $id },
       attribute nullable { 
         some $c in $ch
         satisfies
	 (xs:boolean($c/@nullable) eq true() )
       },
       attribute first { 
         string-join($ch/@first, ' ')
       },
       attribute last { 
         string-join($ch/@last, ' ')
       },
       
       (: follow-set is simple here. :) 
       for $a in $ch/@follow:*
       return $a,
       $children
     }


  else if ($E/self::rule) then
    let $id := $E/@name
         return element {name($E)} {
       $E/@*,
       attribute xml:id { $id },
       attribute nullable { 
         some $c in $ch
         satisfies
	 (xs:boolean($c/@nullable) eq true() )
       },
       attribute first { 
         string-join($ch/@first, ' ')
       },
       attribute last { 
         string-join($ch/@last, ' ')
       },
       
       (: follow-set is simple here. :) 
       for $a in $ch/@follow:*
       return $a,
       $children
     }


  else if ($E/self::comment) then
    $E

  else if ($E/self::ixml) then 
    element ixml {
      $E/@*,
      $children
    }

  else if ($E/self::option or $E/self::sep)
then <error>Element {name($E)} with unexpected content: {$E}</error>
else if ($E/(self::repeat1 or self::repeat0))
then <error>Element {name($E)} with unexpected content: {$E}</error>
else <error>Unexpected element {$E}</error>
};

declare function gl:merge(
  $ids as xs:string*
) as xs:string {
  string-join(distinct-values($ids),' ')
};

declare function gl:read-one-char-spec(
  $s as xs:string
) as xs:string {
  if (string-length($s) eq 1)
  then string($s)
  else if ($s eq '""') 
  then '"' 
  else if ($s eq "''") 
  then "'"
  else if (starts-with($s,'#'))
  then codepoints-to-string(d2x:x2d(substring($s, 2)))
  else ""
};

(: ......................................................
   trace($i, $s):  a utility function to help make code 
   being traced stay more legible.
   :)
declare function gl:trace(
  $x as item()?,
  $s as xs:string
) as item() {
  trace($x, '&#xA;' || $s || '&#xA;')  
};  
declare function gl:notrace(
  $x as item()?,
  $s as xs:string
) as item()? {
  $x 
}; 
(:
declare function gl:trace($x as item()?, $s as xs:string) as item() {
  $x 
};
:)

