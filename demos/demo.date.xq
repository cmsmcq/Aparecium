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
  date: @day, -" ", @month, -" ", @year.
  day: digit, digit?.
  month: "January"; "February"; "March"; "April"; "May"; "June";
         "July"; "August"; "September"; "October"; "November"; "December".
  year: digit, digit, digit, digit.
  -digit: [Nd].
  </grammar>
  
  <test-input>4 November 2021</test-input>
  
</demo>

return <results>{
  for $g in $demo/grammar/string()
  for $i in $demo/test-input/string()
  let $o := aparecium:parse-string($i, $g)
  return <test input="{$i}">{$o}</test>,
  
  if ($demo/options/@show-parsed-grammar = 'yes')
  then for $g in $demo/grammar/string()
       return aparecium:parse-grammar-from-string($g)
  else ()
}</results>