# Aparecium work plan

started 2021-11-05, most recent rev. 2022-06-06

The current work plan for Aparecium is:

* Add new functionality for insertions.  This has several steps:

    * Add insertions to the grammar compiler.

    * Add insertions to the parser.

    * Add insertions to the parse-forest grammar constructor.

    * Add insertions to the parse-tree extractor.

* Work to support more XQuery processors.

  Aparecium currently works with BaseX and Saxon (PE and EE).

  If possible in reasonable time (i.e. days rather than months), make
  Aparecium work with other processors or understand why it's not
  feasible.
  
    * Saxon HE
    * eXist-db
    * FusionDB
    * Mark Logic

  Note that Berkeley DB XML, XQilla, and Xidel do not support
  Aparecium because they support XQuery 1.0 or XQuery 3.0, and thus
  lack support for maps.  Making Aparecium work with them and other
  1.0 or 3.0 processors will require a new representation of items.
  That work is not in the plan at this time (but anyone who would like
  to be able to use Aparecium with such a processor is welcome to
  encourage me to add it to the plan).

* Improve performance.

  * Try to do something about the performance issues:
    Measure. Think. Try something. Repeat.

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


* Do more testing, do better testing.

  * Clean up all tests in ixml-tests repository.  

  * Convert my backlog of tests from 2019 to the current test format,
    run them, pass them.

  * Create a systematic set of negative test cases for the ixml
    grammar (input that does not conform to the ixml grammar for ixml
    grammars); work on error detection and error messages.

  * Create test-coverage tools to measure positive and negative coverage according to various measures.

* Improve the source code.

  * Reorganize and rewrite the SWeb source for Aparecium.  Right now
    it's not a very good advertisement for literate programming.

  * Make Sweb support XSLT scraps, so that I can start writing the
    XSLT version of Aparecium.

  * Implement the remaining parts of the SWeb design.

  * Improve the layout and styling of SWeb documents.

* More work to improve support for other XQuery engines.

  Invest more time making Aparecium work in eXist-db, Fusion-DB, Mark
  Logic, and Saxon HE.

* Better collection of realistic and real grammars.

* Sample applications.

## Done

Not complete, but I want to remind myself that some things do get
done, sometimes.

* Better test harness that runs from the test catalog and produces a test report.

* Rudimentary versioning support in SWeb.

* Better test performance: Pass all tests in the ixml common test
  suite. (Milestone 21 May 2022.)

* Better implementation independence: make Aparecium (and the test
  driver) work with Saxon.  (Milestone 6 June 2022.)

* Corrected test failures for dynamic errors and version mismatch
  (June 2022).

* Rewrote top-level functions to accept user-supplied options and pass
  the options into the internals (29 July 2022).
