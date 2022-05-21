declare namespace tc = "https://github.com/cmsmcq/ixml-tests";
declare namespace th = 'http://blackmesatech.com/2022/iXML/test-harness';

let $test-cases := 
  for $gr in //tc:test-set-results/tc:test-result[@th:parsetime]
  let $pt := number($gr/@th:parsetime),
      $ts := $gr/parent::*/@name/string(),
      $tn := $gr/@name/string(),
      $fn := base-uri($gr),
      $testid := $ts || '/' || $tn
  group by $testid
  return <test-result>{
    attribute name { $testid },
    attribute result { distinct-values($gr/@result)},
    attribute n { count($pt) },
    element mean-parsetime { sum($pt) div count($pt) },
    element min-parsetime { min($pt) },
    element max-parsetime { max($pt) },
    element range { max($pt) - min($pt) },
    element times { for $n in $pt return format-number($n, '9.99') },
    element uri { $fn[1] }
  }</test-result> 
  
for $gt in $test-cases
let $pt := number($gt/mean-parsetime)
order by $pt ascending
return $gt