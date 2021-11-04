module namespace d2x = 'http://blackmesatech.com/2019/iXML/d2x';

(: Decimal / hex conversion utilities. 

   Formerly 'http://www.blackmesatech.com/2014/lib/d2x'.
   :)

(: Revisions:
   2019-04-17 : CMSMcQ : moved to iXML repo
   2015-04-20 : CMSMcQ : revisions of some kind
   2014 : CMSMcQ : made file   
   :)

(: ................................................................
   d2x($n):  return hex numeral string for input integer
   :)
declare function d2x:d2x($n as xs:integer) as xs:string {
  let $r := $n mod 16,
      $c := substring('0123456789ABCDEF', ($n mod 16) + 1, 1),
      $q := ($n - $r) idiv 16
  return if ($q eq 0) then
            $c
         else
            concat(d2x:d2x($q), $c)
};

(: ................................................................
   x2d($n):  evaluate hex numeral string, return integer
   :)
declare function d2x:x2d($hexnum as xs:string) as xs:integer {
  d2x:x2daux(reverse(string-to-codepoints($hexnum)), 0, 1)
};

(: ................................................................
   x2daux($n):  given sequence of codepoints for a hex numeral,
   starting with ones column, then sixteens, then sixty-fours, ...
   return the number.
   :)
declare function d2x:x2daux(
  $codepoints as xs:integer*,
  $accumulator as xs:integer,
  $factor as xs:integer
) as xs:integer {
  d2x:xaux($codepoints, $accumulator, $factor, 16)
};

(: ................................................................
   o2daux($n):  given sequence of codepoints for a hex numeral,
   starting with ones column, then sixteens, then sixty-fours, ...
   return the number.
   :)
declare function d2x:o2daux(
  $codepoints as xs:integer*,
  $accumulator as xs:integer,
  $factor as xs:integer
) as xs:integer {
  d2x:xaux($codepoints, $accumulator, $factor, 8)
};

declare function d2x:xaux(
  $codepoints as xs:integer*,
  $accumulator as xs:integer,
  $factor as xs:integer,
  $base as xs:integer
) as xs:integer {
  if (empty($codepoints)) then 
     $accumulator
  else
     let $digit := $codepoints[1],
         $value := ($digit - string-to-codepoints('0'),
                    $digit + 10 - string-to-codepoints('A'),
                    $digit + 10 - string-to-codepoints('a')
                  )[. ge 0][. le 15][1]
     return d2x:xaux($codepoints[position() gt 1],
                  $accumulator + $value * $factor,
                  $factor * $base,
                  $base)
};

(: ................................................................
   o2d($n):  evaluate octal numeral string, return integer
   :)
declare function d2x:o2d($octalnum as xs:string) as xs:integer {
  
  d2x:o2daux(reverse(string-to-codepoints($octalnum)), 0, 1)
};


(: ................................................................
   o2x($n):  evaluate octal numeral string, return hex
   :)
declare function d2x:o2x($octalnum as xs:string) as xs:string {
  d2x:d2x(d2x:o2d($octalnum))
};


(:
for $i in 1000 to 1099
let $hex := local:d2x($i),
    $dec := local:x2d($hex)
where $i = $dec
return <test init="{$i}" hex="{$hex}" dec="{$dec}"/>
:)