(: compile ixml.xml :)

import module 
    namespace aparecium = "http://blackmesatech.com/2019/iXML/Aparecium"
    at "../build/Aparecium.xqm";
    

let $basedir := '..',
    $libdir := $basedir || '/lib',
    $fn := 'ixml.2021-09-14.ixml.xml',
    $uri := 'file://' || $libdir || '/' || $fn
let $xmlG := doc($uri)
return aparecium:compile-grammar-from-xml($xmlG/ixml)
