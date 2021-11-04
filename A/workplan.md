# Aparecium work plan

2021-11-05

The current work plan for Aparecium is:

* Better testing

  * Make an improved test harness that

    * reads test catalogs conforming to the [schema](https://github.com/cmsmcq/ixml-tests/blob/main/lib/test-catalog.rnc) in the [ixml-tests repository](https://github.com/cmsmcq/ixml-tests)
    * runs the tests
    * compares the produced output to the expected output
    * produces a test report summarizing the results

    Translating to XSpec is one possible approach to this test harness, but my experiences with XSpec for XQuery testing have been a bit mixed.

  * Run and pass the tests in [ixml-tests/tests-straw](https://github.com/cmsmcq/ixml-tests/tree/main/tests-straw) (all subdirectories).

    Note that this may involve revising the test catalogs there to make them conform to the current schema.

* Improve performance

  * Add at least rudimentary support to SWeb (the literate programming system used here) for versioning of code.  (This is a pre-condition for the next item.)

  * Try to do something about the performance issues:  Measure. Think. Try something. Repeat.

Current conjecture 1: Aparecium would do bettter if it had a lexical  
scanner, or the equivalent (a get-token function that could consume in
one step a sequence of input characters which will be serialized in
the output as a single text node or attribute value).

Current conjecture 1: Aparecium would do bettter if it were easier to
build a parse tree from the set of Earley items produced by the
recognizer.  Better indexing, maybe?

* More testing

  * Convert my backlog of tests from 2019 to the current test format, run them, pass them. 

  * Create a systematic set of negative test cases for the ixml grammar (input that does not conform to the ixml grammar for ixml grammars); work on error detection and error messages.

* Improve the source

  * Reorganize and rewrite the SWeb source for Aparecium.  Right now it's not a very good advertisement for literate programming.

  * Make Sweb support XSLT scraps, so that I can start writing the
   XSLT version of Aparecium.

  * Implement the remaining parts of the SWeb design.

  * Improve the layout and styling of SWeb documents.

* Other XQuery engines: Make Aparecium work in eXist-db and Fusion-DB and possibly
others.  (Right now eXist-db can't run Aparecium because they don't current accept a
second argument to map:merge(), and Aparecium needs that.  There are workarounds ...)

* Better collection of realistic and real grammars.

* Sample applications.

