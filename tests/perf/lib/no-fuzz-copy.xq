(: no-fuzz-copy:  read a VCF file, write it back out.
   This does nothing useful but may shed light on why the 
   fuzzed versions don't have the same size as the vcf files.

Revisions:
2022-08-11 : CMSMcQ : copy fuzz-vcf.xq and strip out the actual work.
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
   Write it back out.
:)
let $dir := 'file:///home/cmsmcq/2022/github/Aparecium/tests/perf/vcards/',
    $fn := ('DP.contacts.vcf',
            'NormContacts.vcf',
            'BTU-Addresses-20220811.vcf'
          )[3],
    $vcf := unparsed-text-lines($dir || $fn)
    
for $line in $vcf
return if ($line = ('BEGIN:VCARD', 'END:VCARD'))
then $line
else if (matches($line, '^\s'))
then $line
else if (not(contains($line, ':')))
then trace($line, 'Yow! ')
else let $prefix := substring-before($line, ':'),
         $suffix := substring-after($line, ':')
      return concat($prefix, ':', $suffix)