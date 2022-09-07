import module namespace aparecium 
       = "http://blackmesatech.com/2019/iXML/Aparecium"
       at "file:///home/cmsmcq/2022/github/Aparecium/build/Aparecium.xqm";

let $dir0 := "file:///home/cmsmcq/2022/github/Aparecium/tests/perf/vcards/",
    $dir1 := "file:///home/cmsmcq/2022/github/cmsmcq-ixml/samples/Oberon",
    $g0 := $dir0 || "generic.ixml",
    $g1 := aparecium:parse-grammar-from-uri($g0)
    
return (file:write($dir0 || "generic.aparecium.ixml.xml", 
                   $g1, 
                   map{'indent': 'no'}), 
       $g1)