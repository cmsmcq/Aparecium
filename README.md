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

[Watch this space.]
