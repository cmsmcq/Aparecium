(: extract test strings from a single test catalog :)

declare namespace tc = "https://github.com/invisibleXML/ixml/test-catalog";
declare namespace ixml = "http://invisiblexml.org/NS";

let $catalog := "../xpath/xpath-test-catalog.xml",
    $outdir := "../xpath/temp/"

for $ts in $catalog//tc:test-string
let $testset := $ts/ancestor::tc:test-set/@name/string(),
    $testcase := $ts/ancestors::tc:test-case/@name/string(),
    $fn := concat($testset, '-', $testcase)
    $s := string($ts)

return ($ts, file:write($outdir || $fn, $s)

		 