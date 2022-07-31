import module namespace aparecium 
       = "http://blackmesatech.com/2019/iXML/Aparecium"
       at "../build/Aparecium.xqm";

let $s0 := "ac",
    $g0 := "S = a, +#a, c. a = 'a'. c = 'c'.",
    $s1 := "abcdef",
    $g1 := <grammar> S: [L]+++",". </grammar>,
    $s  := "abc",
    $g  := <grammar> S: [L]++(+":";+'='). </grammar>
    
return aparecium:parse-string($s, $g,
           map {
               'return-grammar': true(),
               'return-items': true(),
               'return-pfg': true()
           })