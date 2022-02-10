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
  <grammar>date: bla, day, S, number, S, month, S, year, bla;
      bla, number, S, month, S, year, bla;
      bla, day, ",", S, number, S, month, S, year, bla. 
day: Monday; Tuesday; Wednesday; Thursday; Friday; Saturday; Sunday.
Monday: "Mon"; "Monday".
Tuesday: "Tue"; "Tuesday".
Wednesday: "Wed"; "Weds"; "Wednesday".
Thursday: "Thu"; "Thur"; "Thurs"; "Thursday".
Friday: "Fri"; "Friday".
Saturday: "Sat"; "Saturday".
Sunday: "Sun"; "Sunday".
number: cardinal; ordinal.
cardinal: digits1, "st"; digits2, "nd"; digits3, "rd"; digits4,"th".
ordinal: digits.
-digits: digit+.
-digit: ["0"-"9"].
-digits1: "1"; digits, "1".
-digits2: "2"; digits, "2".
-digits3: "3"; digits, "3".
-digits4: digit4; digits, digit4.
-digit4: ["4"-"9"]; "0".
-bla: ; char, bla.
-char: [" "-"~"].
month: January; February; March; April; May; June; July; August; September; October; November; December.
year: digit, digit, digit, digit.
January: "January"; "Jan".
February: "February"; "Feb".
March: "March"; "Mar".
April: "April"; "Apr".
May: "May".
June: "June"; "Jun".
July: "July"; "Jul".
August: "August"; "Aug".
September: "September"; "Sept"; "Sep".
October: "October"; "Oct".
November: "November"; "Nov".
December: "December"; "Dec".
-S: " "*.
</grammar>
  <test-input>The conference starts Thursday, 9th Feb 2017 at 10:00.</test-input>
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