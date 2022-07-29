import module namespace aparecium 
       = "http://blackmesatech.com/2019/iXML/Aparecium"
       at "../build/Aparecium.xqm";

let $formula := "../demos/julian-formula.txt",
    $grammar := "../demos/arith2.ixml"
    
return aparecium:parse-resource($formula, $grammar)
