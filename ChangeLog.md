* 1.2.0 (2012.07.24)
  * Added a bunch of tests for LCCN normalization from perl module Business::LCCN
    (http://search.cpan.org/~anirvan/Business-LCCN/)
  * Added ablility to normalize/validate LCCN URIs (e.g., http://lccn.loc.gov/abc89001234)
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
