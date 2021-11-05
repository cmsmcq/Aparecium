# Aparecium
An invisible-XML processor for XQuery and XSLT

Aparecium (the name comes from a spell in the Harry Potter
books, which is used on invisible writing to make it visible)
is a processor for invisible XML.  

Eventually, Aparecium will be available in both XQuery and 
XSLT forms; at this writing (November 2021) only XQuery is
available.  The schedule for the XSLT version is 'real soon 
now'.

## Current status

In its current form, Aparecium is best regarded as a
proof of concept implementation, or a toy.  There may be
specialized situations in which it can be used in real 
applications, but it's currently a bit fragile and very 
slow.

For small inputs (say, under 100 characters), Aparecium works 
reasonably well: that is, compiling a short grammar and using it
to parse a short input string takes a second or so.

For inputs of a few hundred characters, compiling the grammar 
and parsing input may take some tens of seconds.  

For grammars of a few thousand characters (like that for ixml
itself), it currently takes tens of minutes to compile the
grammar.  

## How to use Aparecium to experiment with ixml

The easiest way to play around is to load one of the query modules
from the `demos/` subdirectory into BaseX or Oxygen and
evaluate the query, then modify it and evaluate it again.

*In BaseX, just open the demo you want and click the green "Run query"
button. In Oxygen, you'll need to define an XQuery scenario which
evaluates the current buffer; you may find it convenient to have it
save the output to a file and open it in a buffer.  Then associate
that transformation with file you want to work with, and click the
"Run transformation" button to run the demo.*

There are several demos:

* `demo.date.xq` illustrates one of the date grammars from Steven
Pemberton's
[ixml tutorial](https://homepages.cwi.nl/~steven/ixml/tutorial/tutorial.xhtml)
on the first day of Declarative Amsterdam.

You will see, if you inspect it, that the demo has three main parts:
first it imports the Aparecium module, then it creates an XML element
named `demo`,
with one or more `grammar` elements
and one or more `test-input` elements, and finally it
returns the result of calling `aparecium:parse-string($i, $g)`
for each test-input `$i` and each grammar `$g`.

You can modify the grammar or the input (or both) and re-evaluate
the query to see the effects of your changes.

* `demo.s-expressions.xq` shows a grammar for simple
s-expressions.

It differs from the preceding demo in the way it handles grammars:
instead of parsing and compiling the grammar afresh for every input
string, we compile it once and then use the compiled grammar for each
input string, using the call
`aparecium:parse-string-with-compiled-grammar($i, $cg)`.

For a short grammar like the s-expression grammar, it doesn't matter
much, but for longer grammars, compiling once instead of several times
makes a perceptible difference.

* `demo.uncompiled.xq` is the same as the preceding; the different
name is just to make clear that you should not count on finding any
particular grammar in the demo when you open it.

Unless I have changed it since writing this document, it will contain
a short grammar for the language {'a'} which has the property that the
single sentence in the language has an infinite number of parse trees.
Aparecium selects a couple of them.

* `parse-arithmetic.demo.xq` illustrates the use of a pre-compiled
grammar loaded from disk.  There are four different grammars for
simple arithmetic expressions in the directory, both in their .ixml
form and in their parsed and compiled form.  (The 'parsed' form is
just the grammar in XML format, produced by parsing the ixml grammar
with the grammar for ixml.  The 'compiled' form adds a lot of
attributes to the elements in the parsed form, which you do not need
to understand and which I am not going to try to explain here.)

You can change the filename in the value of the `$g` variable to load
`arith.ixml.compiled.xml`, `arith2`, `arith3`, or `arith4`.  The parse
trees vary somewhat, reflecting the different grammars.

* `parse-english-toy.demo.xq` parses sentences with a pre-compiled
toy grammar of English intended to parse sentences like

    * the cows ate grass.
    * Sarah ate the plant.
    * I saw the cows on the hill with the telescope.

For the last one, Aparecium dutifully reports the various structures
that result from interpreting 'on the hill' and 'with the telescope'
as modifying different nouns.

* `parse-with-compiled-grammar.xq` is a generic form with
the same structure as the preceding two demos; it loads a
compiled grammar and uses it to parse the test input strings.

* `compile-a-grammar.xq` is what I use to (re-)compile grammars
for use with the demos that want a pre-compiled grammar.  I use it
whenever the grammar gets large and complicated enough that I don't
want to have to re-compile it for every batch of test input strings.

Note that although BaseX reads the grammar using a relative URI
without difficulty, it will write out the resulting file in your home
directory if you don't provide a full URI.  The variable `$option` is
just a simple way to get either the parsed version of the grammar
or the compiled version.


## Known bugs and other shortcomings

* It's too slow.  Way too slow.  Sooo sloooooooooooooowwww!

  Short inputs work OK, but if you're thinking of realistically
  sized grammars, this software is not now and may never be what
  you need. But it may be just the trick for figuring out or 
  explaining to others what it is you need.

* It needs more thorough testing.

* Single-character Unicode class codes like `[L]` seem to work
some of the time but not all of the time.  Or maybe they never
work.  Two-character codes do seem to work, so if I write
`[L]` and have trouble, I replace it with `[Ll; Lu; Lt; Lm; Lo]`,
which amounts to the same thing.

* If the input ixml grammar has syntax errors, the `parse-string()`
function does not produce useful error diagnostics.

* If the input grammar is fine but the input is not grammatical,
there are no error diagnostics to speak of; what you get is a
dump of Aparecium's data structures.  Looking at the 'Closure`
element in the result, you will see something like this:

```
    <Closure>
        <item from="3" to="4" rulemark="-" rulename="s" ri="_t_11"/>
        <item from="0" to="4" rulemark="" rulename="rule" ri="s_2"/>
        ...
    </Closure>
```
  The highest value seen for the `item/@to` attribute tells you where in
  the input the parser stopped thinking it understood what was going on.
  Here, the two items say that the parser has managed to recognize the
  string from position 0 to position 4 (so the first several characters of
  the input) as some portion of a *rule*, and the string from 3 to 4 as
  an *s*, or part of an *s*.  So the parse looked OK until position 4 of
  the input.  Then it all turned pear-shaped.

  It is possible to get better diagnostics out of the data structures,
  and one day Aparecium will do so.  Real soon now.
