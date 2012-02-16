# library_stdnums -- simple functions to check and normalize ISSN/ISBN/LCCN

These are a set of Module functions (not classes with methods!) that perform simple checksum verification and (when applicable) normalization on strings containing common library types (currently just ISBN, ISSN, and LCCN).

The code allows for some minimal crap to be in the passed string (e.g., '1234-4568 online' will work fine). All returned ISBN/ISSN values are devoid any dashes; any trailing X for an ISBN/ISSN checkdigit will be uppercase.

When you're getting back just the checkdigit, it will *always be returned as a one-digit string or an uppercase X* ('1'..'9' or 'X'). 


## ISBN

````ruby

      isbn = StdNum::ISBN.normalize(goodISBN)
        # => a 13-digit ISBN with no dashes/spaces
    
      isbn = StdNum::ISBN.normalize(badISBN)
        # => nil (if it's not an ISBN or the checkdigit is bad)
  
      tenDigit = StdNum::ISBN.convert_to_10(isbn13)
      thirteenDigit = StdNum::ISBN.convert_to_13(isbn10)
  
      thirteenDigit,tenDigit = StdNum::ISBN.allNormalizedValues(issn)
        # => array of the ten and thirteen digit isbns if valid; 
        #    an empty array if not
  
      digit = StdNum::ISBN.checkdigit(isbn)
        # => '0'..'9' (for isbn13) or '0'..'9','X' (for isbn10)
  
      if StdNum::ISBN.valid?(isbn)
        puts "#{isbn} has a valid checkdigit"
      end
  
````

# ISSN

````ruby
      issn = StdNum::ISSN.normalize(issn)
      #  => the cleaned-up issn if valid; nil if not
  
      digit = StdNum::ISSN.checkdigit(issn)
      #  => '0'..'9' or 'X'

      if StdNum::ISSN.valid?(issn)
        puts "#{issn} has a valid checkdigit"
      end
````
  
# LCCN

LCCNs are normalized according to the algorithm at http://www.loc.gov/marc/lccn-namespace.html#syntax

````ruby

      lccn = StdNum::LCCN.normalize(rawlccn)
      #  => either the normalized lccn, or nil if it has bad syntax

      if StdNum::LCCN.valid?(rawlccn) {
        puts "#{rawlccn} is valid"
      }

````

## CHANGES
* 1.1.0
  * Changed the ISBN/ISSN regex to make sure string of digits/dashes is at least 6 chars long
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

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010, 2011 Bill Dueber. See LICENSE for details.
