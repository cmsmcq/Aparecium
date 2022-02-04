import module namespace aparecium 
= "http://blackmesatech.com/2019/iXML/Aparecium"
at "../build/Aparecium.xqm";

(: A way to make it a little easier to experiment. :)
let $option := ('parse', 'compile')[2]
let $grammar-fn := 'pascal-comments.1.ixml',
    $output-fn := 'file:///home/cmsmcq/2022/github/Aparecium/demos/'
                  || $grammar-fn || '.' 
                  || $option || 'd.xml',
    $grammar := unparsed-text($grammar-fn) 
                

let $g0 := $grammar,
    $g1 := aparecium:parse-grammar-from-string($g0)
    
return if ($option = 'parse')
       then (file:write($output-fn, $g1), $g1)
       else if ($option = 'compile')
       then let $g2 := aparecium:compile-grammar-from-xml($g1)
            return (file:write($output-fn, $g2), $g2)
       else 'Unknown option'