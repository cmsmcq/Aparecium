import module namespace aparecium 
       = "http://blackmesatech.com/2019/iXML/Aparecium"
       at "../build/Aparecium.xqm";

let $s0 := "ac",
    $g0 := "S = a, +#a, c. a = 'a'. c = 'c'.",
    $s1 := "abcdef",
    $g1 := <grammar> S: [L]+++",". </grammar>,
    $s2 := "abc",
    $g2 := <grammar> S: [L]++(+":";+'='). </grammar>,
    $s3 := "a",
    $g3 := <grammar>S: +#01, 'a' .</grammar>,
    $s  := <test-string>ablebakercharliedog</test-string>,
    $g  := <ixml-grammar>
      -S: a, b, c, d.
      a: 'able'.
      b: 'baker'.
      c: 'charlie'.
      d: 'dog'.
    </ixml-grammar>

return aparecium:parse-string($s3, $g3,
           map {
               'return-grammar': true(),
               'return-items': true(),
               'return-pfg': true()
           })
           (: :)