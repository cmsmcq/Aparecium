(: stratify-ixml-all: read one test report and produce a list of
   grammar / testcase pairs with timing information, sorted by total time
   and including ratio of grammar time to instance time.
   
   2022-08-11 : CMSMcQ : did this to see if I could get more possible
   test cases for some time strata.
 :)

declare namespace tc = "https://github.com/invisibleXML/ixml/test-catalog";
declare namespace t  = "http://blackmesatech.com/2022/iXML/test-harness";

let $dir := 'file:///home/cmsmcq/2022/github/Aparecium/tests/results'
            || '/results-ixml-all-2022-07-30T18:49:16.399/',
    $fn := 'test-report.test-catalog.xml'
    
let $report := doc($dir || $fn)

for $testcase in $report//tc:test-result
let $testset := $testcase/ancestor::tc:test-set-results[1],
    $grammar := ($testset/tc:grammar-result, 
                 $testset/tc:description[@t:parsetime])[1]
where exists($grammar)
let $tsname := $testset/@name/string(),
    $tcname := $testcase/@name/string(),
    $name := concat($tsname, '/', $tcname),
    $gtime := $grammar/@t:parsetime/number(),
    $ctime := $testcase/@t:parsetime/number(),
    $ratio := $gtime div $ctime,
    $time := $gtime + $ctime
                 
order by $time ascending
return <pair n="{$name}" t="{round($time)}" gt="{round($gtime)}" ct="{round($ctime)}" r="{round($ratio)}"/>