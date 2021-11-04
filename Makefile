# Makefile for Aparecium
#
# 2021-11-04
# Put Aparecium.html and xhtml into doc (not build)
#
# 2021-10-04
#
# The only complication here is that every time we re-tangle,
# tangle.xsl generates all the files, whether those scraps
# changed or not.  So we tangle into a temporary directory
# and then use rsync --checksum to copy the output to the
# build directory only if it has changed.

BINDIR=/Users/cmsmcq/bin
XSLTDIR=/Users/cmsmcq/blackmesatech.com/lib

XSLT=$(BINDIR)/saxon-he-wrapper.sh
WEAVEHTML=src/local.xsl

# Aparecium is a literate program.  To generate all outputs,
# weave it and tangle it.

all: tangled woven

# Weave
#
# For the moment, we just weave to HTML; someday it would probably
# be nice to weave to TeX or LaTeX and thence to PDF.

woven: doc/Aparecium.xhtml

doc/Aparecium.xhtml: doc/Aparecium.html
	tidy -output $@ -asxhtml $< 

doc/Aparecium.html: src/Aparecium.xml
	$(XSLT) $< $(WEAVEHTML) $@ 


# Tangle
#
# Note that tmp contains a symbolic link to the tangle stylesheet.
# e.g. (cd tmp; ln -s ../lib/tangle.xsl .)
# That tangle.xsl is a physical copy of the current tangle in the
# SWeb project, and will need to be replaced periodically to pick
# up any improvements.
#

# We use Aparecium.xqm as a canary:  if it is older than the sweb
# source, we retangle everything.
tangled: build/Aparecium.xqm

# As Preston Briggs pointed out a long time ago, we need to produce
# the output and then compare it with what we produced last time,
# to avoid putting a new timestamp on something that has not changed.
# We use rsync to do that and we do it only on *.xqm.  If we end
# up producing other files, this will need to change.  (We could
# do it for everything in tmp, but we don't want to copy tangle.xsl.)
#
# Don't use --archive, it causes updates even when the file has not
# changed.
build/Aparecium.xqm: src/Aparecium.xml
	(cd tmp; $(XSLT) ../$< tangle.xsl zzz.tangle.out)
	rsync --checksum tmp/*.xqm build

