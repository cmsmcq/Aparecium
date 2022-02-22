import module namespace t =
"http://blackmesatech.com/2022/iXML/test-harness"
at "../build/test-harness.xqm";

declare namespace tc =
"https://github.com/cmsmcq/ixml-tests";

declare namespace db =
"http://basex.org/modules/db";

declare option db:chop "false";

let $catalog-index := 'wisp-A' (: which catalog to run? short name :)

let $invdir := "../../ixml/tests/",
    $apadir := "../../Aparecium/tests/",
    $ixtdir := "../../ixml-tests/tests-straw/",
    $outdir := resolve-uri($apadir || 'results-' 
               || $catalog-index 
               || '-'
               || adjust-dateTime-to-timezone(
                    current-dateTime(), () )
               || '/',
               static-base-uri() ),

    $catalog-of-catalogs := <test-catalogs>

      <!-- local catalogs, mostly simple -->
      <catalog n="test0" path="{$apadir}test0.xml"/>
      <catalog n="test1" path="{$apadir}test1.xml"/>
      <catalog n="test2" path="{$apadir}test2.xml"/>
      <catalog n="zeroes" path="{$apadir}zeroes-tests.xml"/>
      <catalog n="misc" path="{$apadir}misc-tests.xml"/>

      <!-- syntax error tests in ixml repo -->
      <catalog n="syntax-cagt"
       path="{$invdir}syntax/catalog-as-grammar-tests.xml"/>
      <catalog n="syntax-caii"
       path="{$invdir}syntax/catalog-as-instance-tests-ixml.xml"/>
      <catalog n="syntax-caix"
       path="{$invdir}syntax/catalog-as-instance-tests-xml.xml"/>

      <!-- other tests in ixml repo -->
      <catalog n="ixml-corr"
	       path="{$invdir}correct/test-catalog.xml"/>
      <catalog n="ixml-ambi"
	       path="{$invdir}ambiguous/test-catalog.xml"/>
      <catalog n="ixml-parse"
	       path="{$invdir}parse/test-catalog.xml"/>

      <!-- ixml-ixml is slow -->
      <catalog n="ixml-ixml"
	       path="{$invdir}ixml/test-catalog.xml"/>
      
      <!-- ixml-all is very slow: 
           all of the tests in the ixml repo -->
      <catalog n="ixml-all"
	       path="{$invdir}test-catalog.xml"/>


      <!-- Positive and negative catalogs for various small grammars -->

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

      <!-- embeds all the gxxx catalogs so they can be done in a single run -->
      <catalog n="gxxx"
	       path="{$ixtdir}gxxx/gxxx-test-catalog.xml"/>

      <!-- arithmetic expressions, with 
           2, 7638, 2886, 1020, and 338 test cases.
           Broken. -->
      <catalog n="arith-pos"
	       path="{$ixtdir}arith/arith.test-catalog.pos.xml"/>
      <catalog n="arith-a-neg"
	       path="{$ixtdir}arith/arith.O3.test-catalog.arc.neg.xml"/>
      <catalog n="arith-af-neg"
	       path="{$ixtdir}arith/arith.O3.test-catalog.arc-final.neg.xml"/>
      <catalog n="arith-s-neg"
	       path="{$ixtdir}arith/arith.O3.test-catalog.state.neg.xml"/>
      <catalog n="arith-sf-neg"
	       path="{$ixtdir}arith/arith.O3.test-catalog.state-final.neg.xml"/>

      <!--  straw-man tests on ixml itself
           (n.b. old version of ixml grammar) -->
      <catalog n="straw-ixml"
	       path="{$ixtdir}ixml/ixml.test-catalog.pos.xml"/>

      <!--  wisps test set (currently in progress) -->
      <catalog n="wisp-A"
	       path="{$ixtdir}wisps/wisps-001-020-catalog.xml"/>
      <catalog n="wisp-B"
	       path="{$ixtdir}wisps/wisps-021-040-catalog.xml"/>
      <catalog n="wisp-C"
	       path="{$ixtdir}wisps/wisps-041-060-catalog.xml"/>
      <catalog n="wisp-D"
	       path="{$ixtdir}wisps/wisps-061-080-catalog.xml"/>
      <catalog n="wisp-E"
	       path="{$ixtdir}wisps/wisps-081-102-catalog.xml"/>

      <catalog n="wisps"
	       path="{$ixtdir}wisps/wisp-catalog.xml"/>
         
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
        ($outdir)[1]
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

let $report := copy $x-report := $report
               modify insert node $summary
                      after $x-report/tc:metadata
               return $x-report


    
return ($report,
        file:write($report-uri, $report))
