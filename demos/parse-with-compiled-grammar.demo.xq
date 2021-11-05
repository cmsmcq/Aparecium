import module namespace aparecium 
= "http://blackmesatech.com/2019/iXML/Aparecium"
at "../build/Aparecium.xqm";

let $g := doc('css.ixml.compiled.xml')/ixml

let $demo := <demo>
  <p>This is a small demo of using ixml from inside an interactive XQuery
  interface.</p>
  <p>Evaluate this query to see the result of parsing the test input below
  using the given grammar. Edit the grammar and test input and re-evaluate
  to see the effects of your changes.</p>  
  <test-input>td {{
    vertical-align: top; 
}}
img {{
    text-align: center;
}}</test-input>
  <test-input>the cows on the hill ate grass.</test-input>

</demo>

return <results>{
    for $i in $demo/test-input/string()
    let $o := aparecium:parse-string-with-compiled-grammar($i, $g)
  return <test input="{$i}">{$o}</test>
}</results>