import module namespace aparecium 
= "http://blackmesatech.com/2019/iXML/Aparecium"
at "../build/Aparecium.xqm";

let $g := doc('pascal-comments.sp.ixml.compiled.xml')/ixml

let $demo := <demo>
  <p>This is a small demo of using ixml from inside an interactive XQuery
  interface.</p>
  <p>Evaluate this query to see the result of parsing the test input below
  using the given grammar. Edit the grammar and test input and re-evaluate
  to see the effects of your changes.</p>  
  <div>
    <p>SP's positive test cases:</p>

    <test-input>(**)</test-input>
    <test-input>(***)</test-input>
    <test-input>(****)</test-input>
    <test-input>(*****)</test-input>
    <test-input>(*abc*)</test-input>
    <test-input>(**abc*)</test-input>
    <test-input>(*abc**)</test-input>
    <test-input>(*abc*abc*)</test-input>
    <test-input>(**abc*abc*)</test-input>
    <test-input>(*abc**abc*)</test-input>
    <test-input>(*abc*abc**)</test-input>
    <test-input>(*abc* )(*abc*)</test-input>
    <test-input>(*abc*)(*abc*)</test-input>
  </div>
  <div>
    <p>MSM's additional positive test cases:</p>
    <!--* (**) is a duplicate *-->
    <!--* (***) is a duplicate *-->
    <!--* (****) is a duplicate *-->
    <test-input>(***a*)</test-input>
    <test-input>(**a*)</test-input>
    <test-input>(**a*a*)</test-input>
    <test-input>(**aa*)</test-input>
    <test-input>(*a*)</test-input>
  </div>
  <div>
    <p>MSM's negative test cases:</p>
    <test-input>(</test-input>
    <test-input>(*</test-input>
    <test-input>(**</test-input>
    <test-input>(***</test-input>
    <test-input>(**a</test-input>
    <test-input>(**a*</test-input>
    <test-input>(**aa</test-input>
    <test-input>(*a</test-input>
    <test-input>(*a*</test-input>
    <test-input>(*aa</test-input>
    <test-input>a</test-input>
    <test-input>)</test-input>
    <test-input>*)</test-input>
    <test-input>**)</test-input>
  </div>
</demo>

return <results>{
    for $i in $demo//test-input/string()
    let $o := aparecium:parse-string-with-compiled-grammar($i, $g)
  return <test input="{$i}">{$o}</test>
}</results>