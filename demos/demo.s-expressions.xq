import module namespace aparecium 
= "http://blackmesatech.com/2019/iXML/Aparecium"
at "../build/Aparecium.xqm";

let $demo := <demo>
  <p>This is a small demo of using ixml from inside an interactive XQuery
  interface.</p>
  <p>Evaluate this query to see the result of parsing the test input below
  using the given grammar. Edit the grammar and test input and re-evaluate
  to see the effects of your changes.</p>
  <options show-parsed-grammar="no"/>
  <grammar>
  item = list; ['0'-'9']+.
  list = -'(', item*s, -')'.
  -s = -' '+.
  </grammar>
  <test-input>4222</test-input>
  <test-input>(1 3 5 (7 9 11) 13)</test-input>
</demo>

return <results>{
  for $g at $ng in $demo/grammar/string()
  let $cg := aparecium:compile-grammar-from-string($g)
  return <tests grammar-number="{$ng}">{
    for $i in $demo/test-input/string()
    let $o := aparecium:parse-string-with-compiled-grammar($i, $cg)
  return <test input="{$i}">{$o}</test>,
  
  if ($demo/options/@show-parsed-grammar = 'yes')
  then aparecium:parse-grammar-from-string($g)
  else ()
  }</tests>  
}</results>