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

BINDIR=/home/cmsmcq/bin

### BINDIR=../../../bin
### XSLTDIR=../../../blackmesatech.com/lib

XSLT=$(BINDIR)/saxon-he-wrapper.sh
WEAVEHTML=src/local.xsl

# Aparecium is a literate program.  To generate all outputs,
# weave it and tangle it.

all: tangled woven testharness

# Weave
#
# For the moment, we just weave to HTML; someday it would probably
# be nice to weave to TeX or LaTeX and thence to PDF.

woven: doc/Aparecium.xhtml

doc/Aparecium.xhtml: doc/Aparecium.html
	-tidy -output $@ -asxhtml $< 2>/dev/null

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
	(cd tmp; $(XSLT) ../$< tangle.xsl zzz.tangle.out version='pfg')
	rsync --checksum tmp/*.xqm build


# Addendum:  test harness.  Same operations (they should perhaps
# be factored out into general rules)`

testharness: tests/test-driver.xq \
		build/test-harness.xqm \
		doc/test-harness.xhtml

build/test-harness.xqm:  src/test-harness.xml
	(cd tmp; $(XSLT) ../$< tangle.xsl zzz.tangle.out version='v2')
	rsync --checksum tmp/test-harness.xqm build
	rsync --checksum tmp/test-driver.xq tests

tests/test-driver.xq:  build/test-harness.xqm
	rsync --checksum tmp/test-driver.xq tests

doc/test-harness.xhtml: doc/test-harness.html
	-tidy -output $@ -asxhtml $< 2>/dev/null

doc/test-harness.html: src/test-harness.xml
	$(XSLT) $< $(WEAVEHTML) $@


## swebtohtml.xsl is shared
lib: lib/swebtohtml.xsl lib/tltohtml.xsl

lib/swebtohtml.xsl: /home/cmsmcq/blackmesatech.com/lib/swebtohtml.xsl
	cp -p $< $@

lib/tltohtml.xsl: /home/cmsmcq/blackmesatech.com/lib/tltohtml.xsl
	cp -p $< $@
