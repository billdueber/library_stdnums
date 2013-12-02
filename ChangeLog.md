* 1.4.1 (2013.12.02)
  * Fixed bug in issn at_least_trying?
* 1.4.0 (2013.10.23)
  * Simplified gemfile/spec process
  * Fixed backwards logic for ISBN.at_least_trying? and added tests
* 1.3.0 (2013.05.24)
  * Added #at_least_trying? to do a basic syntax check for ISSN/ISBN
  * Overload #valid? for ISBN/ISSN such that it returns 'nil' for bad syntax and
    'false' for good-looking syntax, but bad checkdigit
* 1.2.0 (2012.07.24)
  * Added a bunch of tests for LCCN normalization from perl module Business::LCCN
    (http://search.cpan.org/~anirvan/Business-LCCN/)
  * Fix ISBN.normalize to fail if an invalid 10-digit ISBN in passed in
  * Added ablility to normalize/validate LCCN URIs (e.g., http://lccn.loc.gov/abc89001234)
  * Test give 100% code coverage! Yea!
* 1.1.0 (2012.02.06)
  * Changed the ISBN/ISSN regex to make sure string of digits/dashes is at least 6 chars long
  * Cleaned up LCCN validation code
* 1.0.2
  * Made docs clearer.
* 1.0.0
  * Added normalization all around.
  * Added valid? for LCCN.
  * Cleaner code all around, and better docs.
* 0.3.0
  * Wow. ISBN-13 checkdigit wasn't changing '10' to '0'. Blatant error; bad coding *and* testing.
* 0.2.2
  * Added ISSN.valid?
  * Fixed error in ISSN.checksum when checksum was zero (was returning integer instead of string '0')
* 0.2.1
  * Oops. Forgot to check to make sure there are *any* digits in the ISBN. fixed.
* 0.2.0
  * Added allNormalizedValues for ISBN
* 0.1.0
  * Initial release
