import module namespace aparecium 
= "http://blackmesatech.com/2019/iXML/Aparecium"
at "../build/Aparecium.xqm";

declare variable $file as xs:string external;

let $xml-grammar := doc($file),
    $compiled-grammar := aparecium:compile-grammar-from-xml($xml-grammar/ixml)
return $compiled-grammar
