import module namespace aparecium 
= "http://blackmesatech.com/2019/iXML/Aparecium"
at "../build/Aparecium.xqm";

let $g := doc('../demos/ndw.Unicode-data.bnf.ixml.compiled.xml')/ixml

let $demo := <demo>
  <p>This is a small demo of using ixml from inside an interactive XQuery
  interface.</p>
  <p>Evaluate this query to see the result of parsing the test input below
  using the given grammar. Edit the grammar and test input and re-evaluate
  to see the effects of your changes.</p>  
  <test-input>00E0;LATIN SMALL LETTER A WITH GRAVE;Ll;0;L;0061 0300;;;;N;LATIN SMALL LETTER A GRAVE;;00C0;;00C0
00E1;LATIN SMALL LETTER A WITH ACUTE;Ll;0;L;0061 0301;;;;N;LATIN SMALL LETTER A ACUTE;;00C1;;00C1
00E2;LATIN SMALL LETTER A WITH CIRCUMFLEX;Ll;0;L;0061 0302;;;;N;LATIN SMALL LETTER A CIRCUMFLEX;;00C2;;00C2
00E3;LATIN SMALL LETTER A WITH TILDE;Ll;0;L;0061 0303;;;;N;LATIN SMALL LETTER A TILDE;;00C3;;00C3</test-input>

</demo>

return <results>{
    for $i in $demo/test-input/string()
    let $o := aparecium:parse-string-with-compiled-grammar($i, $g)
  return <test input="{$i}">{$o}</test>
}</results>