import module namespace t =
"http://blackmesatech.com/2022/iXML/test-harness"
at "../build/test-harness.xqm";

declare namespace tc =
"https://github.com/cmsmcq/ixml-tests";

declare namespace db =
"http://basex.org/modules/db";

declare option db:chop "false";

let $catalog-number := 1 (: which catalog to run? 1..31 or so :)

let $invdir := "../../ixml/tests/",
    $apadir := "../../Aparecium/tests/",
    $ixtdir := "../../ixml-tests/tests-straw/",
    $outdir := resolve-uri($apadir || 'results-' 
               || adjust-dateTime-to-timezone(
                    current-dateTime(), () )
               || '/',
               static-base-uri() ),

    $test-catalog-path := 
        (

         (: 1 2 3 :)
         $apadir || "test0.xml",
         $apadir || "test1.xml",
         $apadir || "test2.xml",

         (: 4 5 6 :)
         $invdir || "syntax/catalog-as-grammar-tests.xml",
         $invdir || "syntax/catalog-as-instance-tests-ixml.xml",
         $invdir || "syntax/catalog-as-instance-tests-ixml.xml",

         (: 7 8 9 :)
         $invdir || "correct/test-catalog.xml",
         $invdir || "ambiguous/test-catalog.xml",
         $invdir || "parse/test-catalog.xml",

         (: 10 slow :)
         $invdir || "ixml/test-catalog.xml",

         (: 11 very slow - all of the tests in the ixml repo :)
         $invdir || "test-catalog.xml",


         (: Positive and negative catalogs for various small
            grammars :)
         (: 12 13 14 15 :)
         $ixtdir || "gxxx/g010.test-catalog.xml",
         $ixtdir || "gxxx/g010.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g011.test-catalog.xml",
         $ixtdir || "gxxx/g011.O3.test-catalog.all.neg.xml",

         (: 16 - 20 :)
         $ixtdir || "gxxx/g012.test-catalog.xml",
         $ixtdir || "gxxx/g012.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g022.test-catalog.xml",
         $ixtdir || "gxxx/g022.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g101.test-catalog.xml",

         (: 21 - 25 :)
         $ixtdir || "gxxx/g101.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g102.test-catalog.xml",
         $ixtdir || "gxxx/g102.O3.test-catalog.all.neg.xml",
         $ixtdir || "gxxx/g112.test-catalog.xml",
         $ixtdir || "gxxx/g112.O3.test-catalog.all.neg.xml",

         (: 26-30, with 2, 7638, 2886, 1020, and 338 test cases.
            The positive test cases are broken. :)
         $ixtdir || "arith/arith.test-catalog.pos.xml",
         $ixtdir || "arith/arith.O3.test-catalog.arc.neg.xml",
         $ixtdir || "arith/arith.O3.test-catalog.arc-final.neg.xml",
         $ixtdir || "arith/arith.O3.test-catalog.state.neg.xml",
         $ixtdir || "arith/arith.O3.test-catalog.state-final.neg.xml",

         (: 31:  straw-man tests on ixml itself
            (n.b. old version of ixml grammar) :)
         $ixtdir || "ixml/ixml.test-catalog.pos.xml",

         (: 32:  wisps test set (currently in progress) :)
         $ixtdir || "wisps/wisp-catalog.pos.xml"

         
         )[$catalog-number],

    $test-catalog-uri := resolve-uri($test-catalog-path, 
                                     static-base-uri()),

    $report-filename := 'test-results.' 
                        || replace($test-catalog-uri,
                                   "^(.*)/([^/]*)(\.xml)",
                                   "$2")
                        || '.xml', 
    $report-uri := $outdir || $report-filename,

    $options := element options {
      attribute details { 
        ('inline', 
        'by-case', 
        'none')[2]
      },
      attribute input-grammar {
        ('inline',
        'inline-if-short', 
        'external',
        'none')[2]
      },
      attribute input-string {
        ('inline', 
        'inline-if-short', 
        'external',
        'none')[2]
      },
      attribute reported-result {
        ('inline', 
        'inline-if-short',
        'external',
        'none')[1]
      },
      attribute expected-result {
        ('inline', 
        'inline-if-short',
        'external',
        'none')[1]
      },
      attribute files-on-failure {
        ('yes', 
        'no')[1]
      },
      attribute inline-string-limit {
        400 
      },
      attribute inline-xml-limit {
        10
      },
      attribute output-directory {
        ($outdir)[1]
      }
    }


let $dummy   := file:create-dir($outdir),
    $results := t:run-tests($test-catalog-uri, $options)
    
return ($results,
        file:write($report-uri, $results))
