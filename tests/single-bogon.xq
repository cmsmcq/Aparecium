import module namespace aparecium 
       = "http://blackmesatech.com/2019/iXML/Aparecium"
       at "file:///home/cmsmcq/2022/github/Aparecium/build/Aparecium.xqm";

let $options := map {
                  'return-grammar' : false(),
                  'return-items': false(),
                  'return-pfg': false(),
                  'return-tree': true()
                },
    (: s1, g1:  rootless / textnode-at-root :)
    $s1 := <test-string>ablebakercharliedog</test-string>,
    $g1 := <ixml-grammar>
      -S: a, b, c, d.
      -a: 'able'.
      -b: 'baker'.
      -c: 'charlie'.
      -d: 'dog'.
    </ixml-grammar>,
    $s2 := <test-string>aB</test-string>,
    $g2 := <ixml-grammar>
      S: xmlns, able, baker.
      @xmlns: +'http://example.com/this-does-not-work'.
      able: 'a'*.
      baker: 'B'?.
    </ixml-grammar>,
    
    $suri := "perf/oberon/in/oberon-08.Mod.txt", 
    $guri := "perf/oberon/out/Oberon.aparecium.ixml.xml",
    $s4uri := "perf/vcards/hidden/DP.06.contacts.vcf", 
    $g4uri := "perf/vcards/out/generic.aparecium.ixml.xml",
    
    $s := unparsed-text($s4uri),
    $gc := aparecium:compile-grammar-from-xml(doc($g4uri)/*)  
    
return aparecium:parse-string-with-compiled-grammar($s, $gc , $options )

(:
return (
       aparecium:parse-string(
         unparsed-text($s4uri), 
         unparsed-text($g4uri), 
         $options)
     )
:)