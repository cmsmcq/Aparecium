(: compile ixml.xml :)

import module 
    namespace aparecium = "http://blackmesatech.com/2019/iXML/Aparecium"
    at "../build/Aparecium.xqm";
    

let $basedir := '/home/cmsmcq/2022/github/Aparecium',
    $libdir := $basedir || '/lib',
    $fn := 'ixml.2022-04-15.ixml.xml',
    $uri := 'file://' || $libdir || '/' || $fn
let $xmlG := doc($uri)
return aparecium:compile-grammar-from-xml($xmlG/ixml)