# Aparecium work plan

2021-11-05, rev. 2022-04-18, 2022-05-21

The current work plan for Aparecium is:

* Better test performance

  * Pass all tests in the ixml common test suite.

* Implementation independence

  * Make Aparecium work with Saxon.

  * If possible in reasonable time, make Aparecium work with other processors or understand why it's not feasible.
    * Mark Logic
    * eXist-db
    * FusionDB

  (Note that Berkeley DB XML does not support Aparecium because it is XQuery 1.0 and does not support maps.  Supporting it and other 1.0 processors will require a new representation of items.)

* Improve performance

  * Try to do something about the performance issues:  Measure. Think. Try something. Repeat.

Observation: Aparecium does better parsing with the spec grammar if
the grammar is flattened by inlining all hidden nonterminals; I
believe the reason is that it builds fewer items and has fewer items
to manage.  On the group-maintained test suite, this improves run time
by about a factor of four.

Current conjecture 1:  Aparecium would do bettter if it  had a lexical
scanner, or the equivalent (a get-token function that could consume in
one step  a sequence of input  characters which will be  serialized in
the output as a single text node or attribute value).  (Referred to in
some descriptions as the Sugar, Bruno, and Brown Sugar optimizations.)

Conjecture 2: Aparecium would do bettter if it were easier to build a
parse tree from the set of Earley items produced by the recognizer.
Better indexing, maybe?

Conjecture 3: On long grammars and long input, Aparecium would do
bettter if it flattened the input grammar.  For some grammar/input
pairs the extra cost of processing the grammar will outweigh any gain
in the parsing of the input string; not clear where the break-even
point lies.

Conjecture 4: Optimizing the search for Earley items would improve
performance.

Conjecture 5: Inlining frequently called functions may help in some
processors.  (It will not help if the processor already does this.)

Conjecture 6: Direct construction of the parse tree will be faster
than first constructing a parse-forest grammar and then a parse tree.
(The parse forest grammar has roughly twice as many nodes as the parse
tree it describes.)

Conjecture 7: Using a recursive descent parser on input grammars will
improve performance.


* More testing, better testing

  * Extend test schema to handle error codes.

  * Clean up all tests in ixml-tests repository.  

  * Convert my backlog of tests from 2019 to the current test format, run them, pass them. 

  * Create a systematic set of negative test cases for the ixml grammar (input that does not conform to the ixml grammar for ixml grammars); work on error detection and error messages.

  * Create test-coverage tools to measure positive and negative coverage according to various measures.

* Improve the source

  * Reorganize and rewrite the SWeb source for Aparecium.  Right now it's not a very good advertisement for literate programming.

  * Make Sweb support XSLT scraps, so that I can start writing the
   XSLT version of Aparecium.

  * Implement the remaining parts of the SWeb design.

  * Improve the layout and styling of SWeb documents.

* Other XQuery engines: Make Aparecium work in eXist-db and Fusion-DB
and possibly others.  (Right now eXist-db can't run Aparecium because
they don't current accept a second argument to map:merge(), and
Aparecium needs that.  There are workarounds ...)

* Better collection of realistic and real grammars.

* Sample applications.

## Done

* Better test harness that runs from the test catalog and produces a test report.

* Rudimentary versioning support in SWeb.

