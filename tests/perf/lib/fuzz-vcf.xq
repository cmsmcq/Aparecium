(: fuzz-vcf:  read a VCF file, fuzz the data, so the structure of the 
vCard is retained but data are fuzzed so they cannot be read.  

Revisions:
2022-08-11 : CMSMcQ : made first version, for performance testing with vCard
                      data.  I need realistic data, but I don't actually need
                      to read people's Rolodexes.
:)

(: local:fuzz($s): given string $s, return a string of the same length
with all letters (a to z) replaced by x and all digits by 9.  Leave 
punctuation and non-ASCII characters alone.
:)
declare function local:fuzz($s as xs:string) as xs:string {
  translate($s,
               'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 
            || 'abcdefghijklmnopqrstuvwxyz'
            || '0123456789',
               'XXXXXXXXXXXXXXXXXXXXXXXXXX' 
            || 'xxxxxxxxxxxxxxxxxxxxxxxxxx'
            || '9999999999'
  )
};

(: Read the file, line by line.
   If it's a VCARD boundary, leave it alone.
   (Otherwise) If it's a continuation line (begins with whitespace), fuzz it 
      (it's all data).
   If it has no colon, something is wrong, so flag it
   Otherwise, fuzz the data (after the colon).
:)
let $dir := 'file:///home/cmsmcq/2022/github/Aparecium/tests/perf/vcards/',
    $fn := ('DP.contacts.vcf',
            'NormContacts.vcf',
            'BTU-Addresses-20220811.vcf'
          )[1],
    $vcf := unparsed-text-lines($dir || $fn)
    
for $line in $vcf
return if ($line = ('BEGIN:VCARD', 'END:VCARD'))
then $line
else if (matches($line, '^\s'))
then local:fuzz($line)
else if (not(contains($line, ':')))
then trace($line, 'Yow! ')
else let $prefix := substring-before($line, ':'),
         $suffix := substring-after($line, ':'),
         $fuzz := local:fuzz($suffix)
      return concat($prefix, ':', $fuzz)