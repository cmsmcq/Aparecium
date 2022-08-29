(: stratify-ixml-tests:  read the timing data from 12 April
   and create grammar/testcase pairs.  Sum the mean parse time
   of grammar and test case to make an estimate of total expected time.
   
   Calculate the ratio of parse time for grammar and test case:
   it may be worth trying to vary that.
:)
let $dir := '/home/cmsmcq/2022/github/Aparecium/A/',
    $ugr := 'file:' || $dir || 'grammar-test-timing-data-0412.xml',
    $utc := 'file:' || $dir || 'test-case-timing-data-0412.xml',
    $ggg := doc($ugr),
    $ccc := doc($utc)
    
(: return $ccc :)

for $gr in $ggg//grammar-result
let $G := $gr/@name/string(),
    $gt0 := $gr/mean-parsetime/number(),
    $gt := round($gt0)
    
for $tcr in $ccc//test-result[starts-with(@name, $G || '/' )]
let $tcn := $tcr/@name/string(),
    $tct0 := $tcr/mean-parsetime/number(),
    $tct := round($tct0),
    $ratio0 := ($gt0 div $tct0),
    $ratio := round($ratio0)
    
let $t := $gt + $tct

order by $t ascending, $tcn ascending
       
return <pair n="{$tcn}" t="{$t}" gt="{$gt}" ct="{$tct}" r="{$ratio}"/>
