import module namespace t =
"http://blackmesatech.com/2022/iXML/test-harness"
at "../build/test-harness.xqm";

declare namespace tc =
"https://github.com/cmsmcq/ixml-tests";

let $syndir := "../../ixml/tests/steven/syntaxtests/",
    $sptdir := "../../ixml/tests/steven/tests-SP-MSM/",
    $spxdir := "../../ixml/tests/steven/",
    $apadir := "../../Aparecium/tests/",
    $ixtdir := "../../ixml-tests/tests-straw/",
    $outdir := resolve-uri($apadir || 'results-' 
               || adjust-dateTime-to-timezone(
                    current-dateTime(), () )
               || '/',
               static-base-uri() ),
    $test-catalog-path := 
        ($spxdir || "catalog.xml",

         (: 2 3 4 :)
         $syndir || "catalog-as-grammar-tests.xml",
         $syndir || "catalog-as-instance-tests-ixml.xml",
         $syndir || "catalog-as-instance-tests-ixml.xml",

         (: 5 :)
         $sptdir || "tests-catalog.xml",
         
         (: 6 7 8 :)
         $apadir || "test0.xml",
         $apadir || "test1.xml",
         $apadir || "test2.xml",

         (: 9-13, with 2, 7638, 2886, 1020, and 338 test cases.
            The positive test cases are broken. :)
         $ixtdir || "arith/arith.test-catalog.pos.xml",
         $ixtdir || "arith/arith.O3.test-catalog.arc.neg.xml",
         $ixtdir || "arith/arith.O3.test-catalog.arc-final.neg.xml",
         $ixtdir || "arith/arith.O3.test-catalog.state.neg.xml",
         $ixtdir || "arith/arith.O3.test-catalog.state-final.neg.xml",

         (: Positive and negative catalogs for various small
            grammars: 14-27 :)
         $ixtdir || "gxxx/g010.test-catalog.xml",
         $ixtdir || "gxxx/g010.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g011.test-catalog.xml",
         $ixtdir || "gxxx/g011.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g012.test-catalog.xml",
         $ixtdir || "gxxx/g012.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g022.test-catalog.xml",
         $ixtdir || "gxxx/g022.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g101.test-catalog.xml",
         $ixtdir || "gxxx/g101.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g102.test-catalog.xml",
         $ixtdir || "gxxx/g102.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g112.test-catalog.xml",
         $ixtdir || "gxxx/g112.O3.test-catalog.all.neg.xml",

         (: 28:  straw-man tests on ixml itself
            (n.b. old version of ixml grammar) :)
         $ixtdir || "ixml/ixml.test-catalog.pos.xml"
         )[7],

    $test-catalog-uri := resolve-uri($test-catalog-path, 
                                     static-base-uri()),

    $report-filename := 'test-results.' 
                        || replace($test-catalog-uri,
                                   "^(.*)/([^/]*)(\.xml)",
                                   "$2")
                        || '.xml', 
    $report-uri := $outdir || $report-filename,
    $options := element options {
      attribute files { 
        ('by-case', 
        'by-outer-set', 
        'none')[1]
      },
      attribute report-input-grammar {
        ('internal', 
        'all',
        'none')[2]
      },
      attribute report-input-string {
        ('internal', 
        'all',
        'none')[2]
      },
      attribute report-result {
        ('native', 
        'reified',
        'none')[2]
      },
      attribute report-expected-result {
        ('on-error',
        'always',
        'none')[1]
      },
      attribute output-directory {
        ($outdir
        )[1]
      }
    }


let $dummy   := file:create-dir($outdir),
    $results := t:run-tests($test-catalog-uri, $options)
    
return ($results,
        file:write($report-uri, $results))
