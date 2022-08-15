import module namespace t =
"http://blackmesatech.com/2022/iXML/test-harness"
at "../build/test-harness.xqm";

declare namespace tc =
"https://github.com/invisibleXML/ixml/test-catalog";

declare namespace file =
"http://expath.org/ns/file";

declare namespace db =
"http://basex.org/modules/db";

declare option db:chop "false";

let $catalog-index := 'bogons' (: which catalog to run? short name :)
    (: bogons ???. 
       test0 2s, test1 5s, hygiene 12s, zeroes 20s.  
       misc 78s, gxxx 153s, wisp-A 100s.
       test2 745s
    :)

let $invdir := "../../cmsmcq-ixml/tests/",
    $apadir := "../../Aparecium/tests/",
    $ixtdir := "../../ixml-tests/tests-straw/",
    $itwdir := "../../ixml-tests/tests-wood/",
    $outdir := resolve-uri($apadir 
                 || 'results' 
                 || '/results-' 
                 || $catalog-index 
                 || '-'
                 || adjust-dateTime-to-timezone(
                      current-dateTime(), () )
                 || '/'
               ,
                 static-base-uri() 
               ),

    $catalog-of-catalogs := <test-catalogs>

            <!--* .......................................................
          * local catalogs, mostly simple 
          * ...................................................... -->

      <!-- need timing ........................................ -->
      <catalog n="expr1" path="{$apadir}expr1-20220415.xml"/><!-- ??? s -->

      <!-- local performance tests (cut off the slow ones for now) -->
      <catalog n="local-doubling" 
               path="{$apadir}doubling-test-catalog.xml"
               /><!-- ??? s -->
      <catalog n="local-tens"
	       path="{$apadir}tenfold-test-catalog.xml"
               /><!-- ??? s -->
      <catalog n="local-evens-and-odds" 
               path="{$apadir}evens-and-odds-test-catalog.xml"
               /><!-- ??? s -->
	       
      <catalog n="bogons" 
               path="{$apadir}bogons-20220731-catalog.xml"
               /><!-- ??? s -->	       
      
    
      <!-- under 60 seconds ................................... -->
      <catalog n="test0" path="{$apadir}test0.xml"/><!-- 2 s -->
      <catalog n="test1" path="{$apadir}test1.xml"/><!-- 5 s -->
      <catalog n="zeroes" path="{$apadir}zeroes-tests.xml"/><!-- 20 s -->
      
      <!-- under 10 minutes ................................... -->      
      <catalog n="misc" path="{$apadir}misc-tests.xml"/><!-- 78.1s -->

      <!-- under 1 hour ....................................... -->      
      <catalog n="test2" path="{$apadir}test2.xml"/><!-- 745 s -->
      
      <!-- over 1 hour ........................................ -->      

      
            <!--* .......................................................
          * Main ixml repo
          * ...................................................... -->

      <!-- all ................................................ -->
      <catalog n="ixml-all"
	       path="{$invdir}test-catalog.xml"
               /><!-- 5.5h -->

      <!-- syntax/* ........................................... -->
      <catalog n="syntax-cagt"
        path="{$invdir}syntax/catalog-as-grammar-tests.xml"
        /><!-- ? s -->
      <catalog n="syntax-caii"
        path="{$invdir}syntax/catalog-as-instance-tests-ixml.xml"
        /><!-- ? s -->
      <catalog n="syntax-caix"
        path="{$invdir}syntax/catalog-as-instance-tests-xml.xml"
        /><!-- ? s -->
      <catalog n="syntax-correct"
        path="{$invdir}syntax/catalog-of-correct-tests.xml"
        /><!-- ? s -->

      <!-- other tests in ixml repo -->
      <catalog n="ixml-ambi"
	       path="{$invdir}ambiguous/test-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-corr"
	       path="{$invdir}correct/test-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-ixml"
	       path="{$invdir}ixml/test-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-parse"
	       path="{$invdir}parse/test-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-error"
	       path="{$invdir}error/test-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-hygiene"
	       path="{$invdir}grammar-misc/test-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-prolog"
	       path="{$invdir}grammar-misc/prolog-tests.xml"
               /><!-- ? s -->
      <catalog n="ixml-insertion"
	       path="{$invdir}grammar-misc/insertion-tests.xml"
               /><!-- ? s -->
      <catalog n="ixml-misc-1"
	       path="{$invdir}misc/misc-001-020-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-misc-2"
	       path="{$invdir}misc/misc-021-040-catalog.xml"
               /><!-- ? s -->
      <catalog n="ixml-misc-3"
	       path="{$invdir}misc/misc-041-060-catalog.xml"
               /><!-- ? s -->

      <!-- ixml-ixml is slow -->

      <!-- performance tests -->
      <catalog n="a-star-twos" 
               path="{$invdir}performance/a-star/doubling-test-catalog.xml"
               /><!-- ??? s -->
      <catalog n="a-star-tens"
	       path="{$invdir}performance/a-star/tenfold-test-catalog.xml"
               /><!-- ??? s -->
      <catalog n="odds-evens" 
               path="{$invdir}performance/evens-and-odds/test-catalog.xml"
               /><!-- ??? s -->	       

      <!-- under 60 seconds ................................... -->
      <!-- under 10 minutes ................................... -->
      <!-- under 1 hour ....................................... -->
      <!-- over 1 hour ........................................ -->
      
            <!--* .......................................................
          * ixml-tests repo
          * ...................................................... -->
      <!-- need timing ........................................ -->
      <catalog n="g010"
	       path="{$ixtdir}gxxx/g010.test-catalog.xml"/>
      <catalog n="g010neg"
	       path="{$ixtdir}gxxx/g010.O3.test-catalog.all.neg.xml"/>
      <catalog n="g011"
	       path="{$ixtdir}gxxx/g011.test-catalog.xml"/>
      <catalog n="g011neg"
	       path="{$ixtdir}gxxx/g011.O3.test-catalog.all.neg.xml"/>
      <catalog n="g012"
	       path="{$ixtdir}gxxx/g012.test-catalog.xml"/>
      <catalog n="g012neg"
	       path="{$ixtdir}gxxx/g012.O3.test-catalog.all.neg.xml"/>
      <catalog n="g022"
	       path="{$ixtdir}gxxx/g022.test-catalog.xml"/>
      <catalog n="g022neg"
	       path="{$ixtdir}gxxx/g022.O3.test-catalog.all.neg.xml"/>
      
      <catalog n="g101"
	       path="{$ixtdir}gxxx/g101.test-catalog.xml"/>
      <catalog n="g101neg"
	       path="{$ixtdir}gxxx/g101.O3.test-catalog.all.neg.xml"/>
      <catalog n="g102"
	       path="{$ixtdir}gxxx/g102.test-catalog.xml"/>
      <catalog n="g102neg"
	       path="{$ixtdir}gxxx/g102.O3.test-catalog.all.neg.xml"/>
      <catalog n="g112"
	       path="{$ixtdir}gxxx/g112.test-catalog.xml"/>
      <catalog n="g112neg"
	       path="{$ixtdir}gxxx/g112.O3.test-catalog.all.neg.xml"/>

      <!-- under 60 seconds ................................... -->
      <!-- under 10 minutes ................................... -->
      <!-- embeds all the gxxx catalogs so they can be done in a single run -->      
      <catalog n="gxxx"
	       path="{$ixtdir}gxxx/gxxx-test-catalog.xml"/><!-- 153s -->
      <!-- under 1 hour ....................................... -->
      <!-- over 1 hour ........................................ -->
      

    </test-catalogs>,

    $test-catalog-path := $catalog-of-catalogs
                          /catalog[@n=$catalog-index]
                          /@path/string(),

    $test-catalog-uri := resolve-uri($test-catalog-path, 
                                     static-base-uri()),

    $report-filename := 'test-report.' 
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
        (
          concat($outdir, file:create-dir($outdir))
        )[1]
      },
      
      attribute timeout { 600 }

    }


let $dummy  := file:create-dir($outdir),
    $report := t:run-tests($test-catalog-uri, $options)

let $grammar-tests := $report//tc:grammar-result
let $gt-summary := element tc:p {
                     "Grammar tests (" 
                     || count($grammar-tests)
                     || "): ",
                     for $gt in $grammar-tests
                     let $res := $gt/@result/string()
                     group by $res
                     return $res[1] || ": " || count($gt) || '. '
                   }
let $test-cases := $report//tc:test-result
let $tc-summary := element tc:p {
                     "Test cases (" 
                     || count($test-cases)
                     || "): ",
                     for $gt in $test-cases
                     let $res := $gt/@result/string()
                     group by $res
                     return $res[1] || ": " || count($gt) || '. '
                   }
let $summary := element tc:description {
                  element tc:p {
                    "Tests run / passed / failed"
                    || " / not-run / other:"
                  },
                  $gt-summary,
                  $tc-summary
                }

let $report := element {name($report)} {
                 $report/@*,
                 $report/tc:metadata[1]
                     /preceding-sibling::node()
                     /self::node(),
                 $report/tc:metadata[1],
                 $summary,
                 $report/tc:metadata[1]
                     /following-sibling::node()
               }


    
return ($report,
        file:write($report-uri, $report))
