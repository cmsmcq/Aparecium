module namespace t =
"http://blackmesatech.com/2022/iXML/test-harness";
declare namespace tc =
"https://github.com/cmsmcq/ixml-tests";

declare namespace db =
"http://basex.org/modules/db";

import module namespace ap =
"http://blackmesatech.com/2019/iXML/Aparecium"
at "Aparecium.xqm";



declare function t:run-tests(
  $catalog-uri as xs:string,
  $options as element(options)
) as element(tc:test-report) {

  
  let $catalog := try { 
    doc($catalog-uri)/*
  } catch err:FODC0002 {
    <no-such-catalog/>
  }

  return element tc:test-report {
    
    attribute t:creator { "Aparecium test harness v2" },
    element tc:metadata {
      element tc:name {
        'Test results for ' || $catalog/@name
      },
      element tc:report-date { 
        current-dateTime()
      },
      element tc:processor { "Aparecium" },
      element tc:processor-version { "v0.1" },
      element tc:catalog-uri { $catalog-uri },
      element tc:catalog-date { 
        ($catalog/@release-date/string(), '??')[1] 
      },
      element tc:description {
        element tc:p {
          text { "Test report generated by test-harness.xqm." }
        }
      }
    },


    
    if ($catalog/self::no-such-catalog) then
      element tc:error {
        attribute id { "tc:tbd01" },
        element tc:p {
          text { "Nothing found at "},
          $catalog-uri,
          text { "." }
        }
      }
    else

    for $test-set in $catalog/*
        [self::tc:test-set or self::tc:test-set-ref]
    return t:run-test-set($test-set, 
                          (), 
                          $catalog-uri, 
                          $options)
  }
};


declare function t:run-test-set(
  $test-set as element(),
  $options as element(options)
) as element() {
  t:run-test-set($test-set, (), (), $options)
};

declare function t:run-test-set(
  $test-set as element(),
  $grammar as element()?,
  $uri-stack as xs:string*,
  $options as element(options)
) as element()+ {

  if ($test-set/self::tc:test-set-ref)
  then 
       let $uri0 := base-uri($test-set),
           $uri1 := string($test-set/@href),
           $uri2 := resolve-uri($uri1, $uri0),
           $newcat := try {
             doc($uri2)
           } catch err:FODC0002 { 
             <no-such-test-set/> 
           }
       return if ($newcat/self::no-such-test-set) then
           element tc:error {
             attribute id { "tc:tbd02" },
             element tc:p {
               text { "Nothing found at "},
               $uri2,
               text { "." }
             }
           }
        else for $test-set 
             in $newcat/*/*
                [self::tc:test-set 
                or self::tc:test-set-ref]
             return t:run-test-set($test-set, 
                                   $grammar, 
                                   ($uri2, $uri-stack),
                                   $options)

  else 
    let $test-set-name := trace(
                            $test-set/@name/string(),
                            "Starting test set: ")
          
      let $nxg-plus := prof:track(
          if ($test-set/tc:ixml-grammar)
          then 
          try {
                ap:parse-grammar-from-string(
                    $test-set/tc:ixml-grammar/string()
                )
          } catch * {
               element tc:error {
                 attribute id { "t:tbd04" },
                 text { "ixml compilation failed" }
               }               
          }

          else if ($test-set/tc:vxml-grammar)
          then           $test-set/tc:vxml-grammar[1]/*

          else if ($test-set/tc:ixml-grammar-ref)
          then 
          let $uri0 := $test-set/tc:ixml-grammar-ref
                           /@href/string(),
              $uri1 := base-uri($test-set),
              $uri2 := resolve-uri($uri0, $uri1)
              return 
                if (unparsed-text-available($uri2))
                then try {
                       ap:parse-grammar-from-uri($uri2)
                     } catch * {
                       element tc:error {
                         attribute id { "t:tbd06" },
                         text { "ixml compilation failed" }
                       }
                     }
                else element tc:error {
                       attribute id { "t:tbd07" },
                       text { "external ixml not found" }
                     }
 
          else if ($test-set/tc:vxml-grammar-ref)
          then 
          let $uri0 := $test-set/tc:vxml-grammar-ref
                           /@href/string(),
              $uri1 := base-uri($test-set),
              $uri2 := resolve-uri($uri0, $uri1)
          return if (doc-available($uri2))
                 then let $xmlTmp := doc($uri2)
                      return if (exists($xmlTmp/ixml))
                             then $xmlTmp/ixml
                             else element tc:error {
                                    attribute id {"t:tbd08"},
                                    $uri0,
                                    "(" || $uri2 || ")",
                                    " is not an ixml grammar."
                             }
                 else element tc:error {
                        attribute id { "t:tbd09" },
                        text { "external vxml grammar"
                              || " not found at " },
                        $uri0,
                        text { " (i.e. "  },
                        $uri2,
                        text { ")." }
                      }
          

          else ()
          ),
          $new-xml-grammar := $nxg-plus?value
          

      
      let $checked-xml-grammar := 
          if (empty($new-xml-grammar))
          then ()
          else if ($new-xml-grammar/self::ixml)
          then $new-xml-grammar
          else element tc:error {
            attribute id { "t:tbd10" },
            text { "XML grammar not conformant:" },
            $new-xml-grammar
          }

      
      let $grammar := if (exists($new-xml-grammar)
                         and $checked-xml-grammar/self::ixml)
          then try {
            ap:compile-grammar-from-xml($checked-xml-grammar)
          } catch * {
            element tc:error {
              attribute id {"t:tbd11"},
              text { 
                "Error compiling grammar"
              }
            }
          }
      else $grammar


    
    let $gt := $test-set/tc:grammar-test,
        $parsetime := attribute t:parsetime {
                        $nxg-plus?time
                      }
    let $grammar-test-result := 
        if (exists($gt))
        then (copy $gtr := t:test-grammar($gt, 
                            $checked-xml-grammar, 
                            $options)
             modify insert node $parsetime 
                           into $gtr
             return $gtr
             )
        else element tc:description {
               $parsetime,
               element tc:p {
                 "Grammar parse time: ",
                 $nxg-plus?time
               }              
             }

    return element tc:test-set-results {
          $test-set/@*, 
          
        if (($options/@details = 'by-case')
           and exists($grammar-test-result
                      /self::tc:grammar-result))
        then (element tc:grammar-result {
                $grammar-test-result/@*
             }, 
             let $outfn := 'grammar-test-' 
                           || $test-set-name 
                           || '-results.xml',
                 $out := concat(
                         $options/@output-directory, 
                         '/', $outfn)
             return file:write($out, $grammar-test-result)
             )

        else $grammar-test-result
        ,

              if ($checked-xml-grammar/self::tc:error)
    then (element tc:description {
           element tc:p {
             "No workable grammar.  Skipping test",
             "&#xA;cases and nested test sets."
           }
         },
         element tc:app-info { $checked-xml-grammar }
         )
    else if (exists($checked-xml-grammar)
             and 
             not($checked-xml-grammar/self::ixml))
    then (element tc:description {
           element tc:p {
             "No workable grammar.  Skipping test",
             "&#xA;cases and nested test sets.",
             "&#xA;This case is not supposed to happen."
           }
         },
         element tc:app-info { $checked-xml-grammar }
         )
    else if ($grammar-test-result/@result ne 'pass')
    then element tc:description {
           element tc:p {
             "Failed grammar test.  Skipping test",
             "&#xA;cases and nested test sets."
           }
         }
    else if ($grammar/self::tc:error)
    then (element tc:description {
           element tc:p {
             "Grammar compilation failed.  Skipping",
             "&#xA; test cases and nested test sets."
           }
         },
         element tc:app-info { $grammar }
         )

          else 
      for $c in $test-set/*
          [self::tc:test-set 
          or self::tc:test-set-ref
          or self::tc:test-case]
      return if ($c/self::tc:test-set 
                or $c/self::tc:test-set-ref)
      then t:run-test-set($c, 
                          $grammar, 
                          $uri-stack, 
                          $options)
      else if ($c/self::tc:test-case)
      then t:run-test-case($c, $grammar, $options)
      else element tc:error {
        attribute id { "t:tbd03" },
        text { "The laws of logic have been abrogated?" }
      }

        }

};


declare function t:test-grammar(
  $grammar-test as element(tc:grammar-test),
  $xml-grammar as element(),
  $options as element(options)
) as element(tc:grammar-result) {
  
  let $e0 := $grammar-test/tc:result/*[1],
      $expectation :=
        if ($e0/self::tc:assert-xml-ref)
        then let $uri0 := $e0/@href/string(),
                 $uri1 := base-uri($grammar-test),
                 $uri2 := resolve-uri($uri0, $uri1)
             return if (doc-available($uri2))
                    then (doc($uri2)/ixml,
                         element tc:error {
                           attribute id { "t:tbd12" },
                           $uri2,
                           " is not an ixml grammar."
                         })[1]
                    else element tc:error {
                      attribute id { "t:tbd13" },
                      $uri2,
                      text { " not found." }
                    }
        else if ($e0/self::tc:assert-xml/ixml)
        then $e0/ixml
        else $e0 (: assert-not-a-{grammar,sentence} :)

  
  return element tc:grammar-result {
    
    if ($expectation/self::tc:error)
    then ( 
           attribute result { "not-run" },
           element tc:description {
             element tc:p {
               "Expected result not found."
             } 
           },
           element tc:app-info {
             $expectation 
           }
         )

    else if ($xml-grammar/self::tc:error
             [@id = ("t:tbd07", "t:tbd08", "t:tbd09")])
    then (
           (: grammar parsed but was nonconformant :)
           attribute result { "not-run" },
           element tc:result {
             $expectation
           },
           element tc:app-info { $xml-grammar }
         )

    else if ($expectation[self::tc:assert-not-a-grammar
             or self::tc:assert-not-a-sentence]
             and
             ($xml-grammar/self::tc:error[@id = 
             ("t:tbd04", "t:tbd06")]
             or $xml-grammar/self::no-parse
             or $xml-grammar/child::no-parse
             )
            )
    then (
           (: grammar did not parse :)
           attribute result { "pass" },
           element tc:result {
             $expectation
           },
           element tc:app-info { $xml-grammar }
         )

    else if ($expectation[self::tc:assert-not-a-grammar]
             and
             $xml-grammar/self::tc:error
                          [@id = "t:tbd10"])
    then (
           (: grammar parsed but was nonconformant :)
           attribute result { "pass" },
           element tc:result {
             $expectation
           },
           element tc:app-info { $xml-grammar }
         )

    else if ($xml-grammar/self::tc:error)
    then (
           attribute result { "fail" },
           element tc:result {
             $expectation
           },
           element tc:description {
             element tc:p {
               "Unexpected error in gramar parameter."
             }
	   },
           element tc:app-info { $xml-grammar }
         )
  
    
    else if (deep-equal($xml-grammar, $expectation))
    then (
           (: grammar conformant and as expected :)
           attribute result { "pass" }
         )

      else (
         (: grammar conformant but not as expected :)
         attribute result { "fail" },
         element tc:result {
           comment {
            "diagnostics should go here"
           },
           element tc:assert-xml { $expectation },
           element tc:reported-xml { $xml-grammar }
         }
       )

  }

};


declare function t:run-test-case(
  $test-case as element(tc:test-case),
  $G as element()?,
  $options as element(options)
) as element() {
    let $dummy := trace($test-case/@name/string(),
                      "Starting test case: ")
  let $failure-string := ("󠁎󠁏󠁔"
                      || "󠀠󠁆󠁏"
                      || "󠁕󠁎󠁄"
                         (: 'NOT FOUND' in tag block :),
                         "𝍐",
                         "�")[2]

    let $test-set-parent := $test-case/parent::tc:test-set,
        $test-set-grammar-host := $test-case/
            ancestor::tc:test-set
            [tc:ixml-grammar or tc:vxml-grammar
            or tc:ixml-grammar-ref
            or tc:vxml-grammar-ref]
            [1],
        $test-set-name := $test-set-parent/@name/string(),
        $grammar-name := 'grammar-' 
                         || $test-set-grammar-host
                            /@name/string()
                         || '.xml',
        $test-case-ID := concat($test-set-name, 
                                '-', 
                                $test-case
                                /@name/string())

  
    let $input-string := 
        if ($test-case/tc:test-string)
        then string($test-case/tc:test-string)
        else if ($test-case/tc:test-string-ref)
        then let $uri0 := $test-case
                          /tc:test-string-ref/@href
                          /string(),
                 $uri1 := base-uri($test-case),
                 $uri2 := resolve-uri($uri0, $uri1)
             return 
                 if (unparsed-text-available($uri2))
                 then unparsed-text($uri2)
                 else $failure-string
        else "Ich versteh die Welt nicht mehr"

  
    let $expectations := 
        for $e in $test-case/tc:result/*
        return if ($e/self::tc:assert-not-a-sentence)
            then $e
            else if ($e/self::tc:assert-not-a-grammar)
            then $e
            else if ($e/self::tc:assert-xml)
            then $e/*
            else if ($e/self::tc:assert-xml-ref)
            then let $uri0 := $e/@href
                              /string(),
                     $uri1 := base-uri($test-case),
                     $uri2 := resolve-uri($uri0, $uri1)
                 return 
                 if (doc-available($uri2))
                 then doc($uri2)/*
                 else element tc:error {
                   attribute id { "t:tbd14" },
                   "Expected result at ",
                   $uri0,
                   " not found. Looked for ",
                   $uri2
                 }
            else element tc:error {
                   attribute id { "t:tbd17" },
                   "Unexpected expectation ",
                   $e
                 }

  
    let $pt-plus := prof:track(
        
        if ($input-string eq $failure-string)
        then ()
        else if ($expectations/self::tc:error)
        then ()
        else if (not($G/self::ixml))
        then element tc:error {
               attribute id { "t:tbd18" },
               element tc:msg {
                 "This is not an ixml grammar: "
               },
               $G
             }

        else try {
          
          let $query := "import module namespace aparecium
                = 'http://blackmesatech.com/2019/iXML/Aparecium'
                at '../build/Aparecium.xqm';
                declare variable $s external;
                declare variable $g external;
                aparecium:parse-string-with-compiled-grammar($s, $g)",
              $bindings := map {
                             's' : $input-string,
                             'g' : $G
                           },
              $options := map { 
                            'timeout' : 
                            ($options/@timeout/number(), 600)[1]
                          }
          return xquery:eval($query, $bindings, $options)

        } catch xquery:timeout {
          element tc:error {
              attribute id { "t:tbd19" },
              "Parse function timed out at ",
              ($options/@timeout/number(), 600)[1],
	      " seconds."
          }
        } catch * {
          element tc:error {
              attribute id { "t:tbd16" },
              "Parse function blew up. ",
              $err:code, $err:value, 
              " module: ",
              $err:module, 
              "(", $err:line-number, ",", 
              $err:column-number, ")"
          }
        }
        )
    let $parse-tree := $pt-plus?value 

  
    let $result :=
        if ($input-string eq $failure-string)
        then "not-run"
        else if (exists($expectations
                   /self::tc:error)) 
        then "not-run"
        else if (exists($parse-tree
                 /self::tc:error[@id = 't:tbd18'])) 
        then "fail" (: or should this be "not-run"? :)
        else if (exists($parse-tree
                 /self::tc:error[@id = 't:tbd19'])) 
        then "other" (: timed out - or "not-run"? :)
        else if ($parse-tree/self::no-parse
                 and $expectations
                 /self::tc:assert-not-a-sentence)
        then "pass"
        else if ($parse-tree/self::no-parse
                 and $expectations
                 /self::tc:assert-not-a-grammar)
        then "pass" (: This case should not arise :)
        else if ($parse-tree/self::forest
              and 
              empty(($expectations/self::tc:assert-not-a-grammar,
              $expectations/self::tc:assert-not-a-sentence))
              and 
              (every $e1 in $parse-tree/* satisfies
              (some $e2 in $expectations satisfies
              deep-equal($e1, $e2))))
        then "pass" 
        else if (some $e1 in $expectations satisfies
                deep-equal($e1, $parse-tree))
        then "pass"
        else "fail"

  
    let $error-details :=
        if ($input-string eq $failure-string)
        then element tc:error {
               attribute id { "t:tbd15" },
               "External test input not found."
             }
        else if (exists($expectations
                 /self::tc:error)) 
        then $expectations/self::tc:error
        else if (exists($parse-tree
                 /self::tc:error)) 
        then $parse-tree
        else ()

  
    let $details :=
        if ($options/@details = 'none')
        then ()
        else (
            
            let $kw := $options/@input-grammar
            let $g0 := $test-set-grammar-host
                       /*[self::tc:ixml-grammar
                       or self::tc:vxml-grammar
                       or self::tc:ixml-grammar-ref
                       or self::tc:vxml-grammar-ref]

            return if ($kw = ('inline',
                              'inline-if-short'))
            then ($g0/self::tc:ixml-grammar, 
                  $g0/self::tc:vxml-grammar, 
                  element tc:vxml-grammar {$G})[1]
            else if ($kw eq 'external')
            then element tc:vxml-grammar-ref { 
                   attribute href { $grammar-name },
                   (: and let's write the file :)
                   file:write($options/@output-directory
                             || '/' || $grammar-name,
                             $g0)
                 }
            else ()
,
            
            let $kw := $options/@input-string,
                $fn := $test-case-ID || '.input.txt'
            return if (($kw eq 'inline')
                       or
                       (($kw eq 'inline-if-short')
                        and
                        (string-length($input-string)
                        le 
                        ($options/@inline-string-limit
                         /number(), 400)[1])))
            then element tc:test-string {
                   $input-string
                 }
            else if ($kw = ('external', 
                            'inline-if-short'))
            then element tc:test-string-ref { 
                   attribute href { $fn },
                   (: and let's write the file :)
                   file:write($options/@output-directory
                             || '/' || $fn,
                             $input-string)
                 }
            else ()
,
            
            if (
                ($options/@expected-result ne 'none')
                or 
                ($options/@reported-result ne 'none')
                or 
                (($options/@files-on-failure ne 'no')
                 and ($result eq 'fail'))
               )
            then element tc:result {
              
            let $kwD := $options/@expected-result,
                $kwE := $options/@files-on-failure,
                $fn  := $test-case-ID || '.expected.xml'

            return 
            if ($result eq 'fail')

            then if ($expectations
                     [self::tc:assert-not-a-sentence
                     or
                     self::tc:assert-not-a-grammar])
                 then $expectations

                 else ( 
                      if ($kwD = ('inline',
                                  'inline-if-short'))
                      then element tc:assert-xml {
                             $expectations
                           }
                      else (),

                      if (($kwD eq 'external')
                          or
                          ($kwE eq 'yes'))
                      then element tc:assert-xml-ref {
                              attribute href {$fn},
                              file:write(
                                $options/@output-directory
                                || '/' || $fn,
                                $expectations
                              )
                            }
                      else () (: unknown option, bag it :)
                      )

            else () (: $result ne 'fail' :)            
,
              
            let $kwD := $options/@reported-result,
                $kwE := $options/@files-on-failure,
                $fn  := $test-case-ID || '.reported.xml'
            return 
            if ($parse-tree/self::no-parse)
            then (element tc:reported-not-a-sentence{
                    element tc:app-info {
                      $parse-tree
                    }
                 },
                 if (($kwE eq 'yes') 
                    and ($result eq 'fail'))
                 then file:write(
                        $options/@output-directory
                        || '/' || $fn,
                        $parse-tree
                      )
                 else ()
                 )

            else ( 
                   if ($kwD = ('inline', 
                               'inline-if-short'))
                   then element tc:reported-xml {
                          $parse-tree
                        }
                   else (),

                   if (($kwD eq 'external')
                       or
                       (($kwE eq 'yes') 
                        and 
                        ($result eq 'fail'))
                      )
                   then element tc:reported-xml-ref {
                          attribute href {$fn},
                          file:write(
                            $options/@output-directory
                            || '/' || $fn,
                            $parse-tree
                          )
                        }
                   else () (: unknown option :)
                 )

            }
            else ()

        )

  
  return (element tc:test-result {
    $test-case/@*,
    attribute result { $result },
      if (exists($pt-plus))
  then attribute t:parsetime { $pt-plus?time }
  else ()
,
    
    if (exists($error-details))
    then element tc:app-info {
         $error-details
    }
    else ()
,
    if ($options/@details eq 'inline')
    then $details
    else ()
  },
  
        if ($options/@details = 'by-case')
        then let $outfn := $test-case-ID
                           || '-test-result.xml',
                 $out := concat(
                         $options/@output-directory, 
                         '/', $outfn)
             return file:write(
                      $out, 
                      element tc:test-result {
                        $test-case/@*,
                        attribute result { $result },
                        
    if (exists($error-details))
    then element tc:app-info {
         $error-details
    }
    else ()
,
                        $details
                      }
                    )
        else ()

  )
};


