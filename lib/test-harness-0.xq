(: Quick and dirty test-zero test runner. 

   This should be generalized later and put into a module.
:)

(: Revisions:
   2021-10-14 : CMSMcQ : try to make this support grammar
                tests.
   2021-10-05/-10-14 : CMSMcQ : many minor revisions as work 
                proceeds.
   2021-10-05 : CMSMcQ : quick first cut
:)


declare namespace tc = "https://github.com/cmsmcq/ixml-tests";

import module 
    namespace aparecium = "http://blackmesatech.com/2019/iXML/Aparecium"
    at "../build/Aparecium.xqm";

let $fVerbose := ('always', 'never', 'failure')[1]

let $basedir := '..',
    $builddir := $basedir || '/build',
    $testindir := $basedir || '/tests',
    $testoutdir := $testindir || '/output',
    $fn-test-catalog := $testindir || '/test0.xml'
    
let $test-catalog := doc('file://' || $fn-test-catalog)

let $test-suite-results := <tc:test-suite-results>
    <tc:header>
        <tc:ixml-version>2019-09-24</tc:ixml-version>
        <tc:test-catalog href="{$fn-test-catalog}"/>
        <tc:created on="{current-dateTime()}"
                    by="CMSMcQ via test-harness-0.xq"
                    email="cmsmcq@blackmesatech.com"
                    organization="Black Mesa Technologies LLC"/>
        <tc:product name="Aparecium"
                    version="0.2"
                    vendor="Black Mesa Technologies LLC"
                    released="false"
                    open-source="true"/>
    </tc:header>
    
{   for $test-set at $nts in $test-catalog//tc:test-set
    return <tc:test-set name="{$test-set/@name}">{
      
    let $vxml-ts-grammar := 
            for $vg in $test-set/tc:vxml-grammar-ref
            (: calculate correct reference ... :)
            let $gdoc := doc($testindir || '/' || $vg/@href)
            return aparecium:compile-grammar-from-xml($gdoc/ixml)
            (: fetch other grammars.  They should
            all be equivalent ... :)

    for $test-case at $ntc in $test-set/tc:test-case
    let $trace := trace($ntc, 'test-case number: ')
    let $vxml-tc-grammar := 
            for $vg in $test-case/tc:vxml-grammar-ref
            (: calculate correct reference ... :)
            let $gdoc := doc($testindir || '/' || $vg/@href)
            return aparecium:compile-grammar-from-xml($gdoc/ixml),
        $ls := (for $literal in $test-case/tc:test-string
               return string($literal),
               for $ref in $test-case/tc:test-string-ref
               return unparsed-text($testindir||'/'||$ref/@href)
               ),
        $lg := ($vxml-tc-grammar, $vxml-ts-grammar),
        $expected-result := 
            if (exists($test-case/tc:result/tc:assert-xml-ref))
            then doc('file://' || $testindir || '/'
                     || ($test-case/tc:result/tc:assert-xml-ref/@href))
            else $test-case/tc:result/tc:assert-xml/*
        
        for $I at $nI in $ls, $G at $nG in $lg
        let $G2 := $G (: aparecium:compile-grammar-from-xml($G) :),
            $result := aparecium:parse-string-with-compiled-grammar($I, $G2),
            $fWinning := deep-equal($result, $expected-result)
        return <tc:test-case name="{$test-case/@name}" n="{$ntc}">{
            attribute result {
              if ($fWinning) then 'pass' else 'fail'
            },
            if (count($ls) gt 1) 
            then attribute input-version { $nI } 
            else (),
            if (count($lg) gt 1)
            then attribute grammar-version { $nG }
            else (),
            if (($fVerbose = 'always') 
                or 
                (not($fWinning) and $fVerbose eq 'failure'))
            then <tc:app-info>
              <input>{$I}</input>
              <output>{$result}</output>
              { if ($fWinning)
              then ()
              else <expected>{$expected-result}</expected>
            }</tc:app-info>
        }</tc:test-case>    
    }</tc:test-set>
}</tc:test-suite-results>

return (file:write('file://' || $testoutdir 
        || '/test0-' 
        || translate(
            string(adjust-dateTime-to-timezone(current-dateTime(), ())),
            ' :',
            '__')
        || '.xml', 
        $test-suite-results),
        $test-suite-results
      )
      
  
