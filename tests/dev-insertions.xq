import module namespace aparecium 
       = "http://blackmesatech.com/2019/iXML/Aparecium"
       at "../build/Aparecium.xqm";

let $s := "ac",
    $g := "S = a, +#9, c. a = 'a'. c = 'c'."
    
return aparecium:parse-string($s, $g,
           map {
               'return-grammar': true(),
               'return-items': true(),
               'return-pfg': true()
           })