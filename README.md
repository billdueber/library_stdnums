# library_stdnums -- simple functions to check and normalize ISSN/ISBN/LCCN

[![Build Status](https://secure.travis-ci.org/billdueber/library_stdnums.png)](http://travis-ci.org/billdueber/library_stdnums)

These are a set of Module functions (not classes with methods!) that perform simple checksum verification and (when applicable) normalization on strings containing common library types (currently just ISBN, ISSN, and LCCN).

The code allows for some minimal crap to be in the passed string (e.g., '1234-4568 online' will work fine). All returned ISBN/ISSN values are devoid any dashes; any trailing X for an ISBN/ISSN checkdigit will be uppercase.

When you're getting back just the checkdigit, it will *always be returned as a one-digit string or an uppercase X* ('1'..'9' or 'X').


## ISBN

We can deal with 10 or 13-digit ISBNs and convert between the two (when applicable).
"Normalization" means converting to 13-digit string and then validating.

~~~~~

      isbn = StdNum::ISBN.normalize(goodISBN)
        # => a 13-digit ISBN with no dashes/spaces

      isbn = StdNum::ISBN.normalize(badISBN)
        # => nil (if it's not an ISBN or the checkdigit is bad)

      tenDigit = StdNum::ISBN.convert_to_10(isbn13)
      thirteenDigit = StdNum::ISBN.convert_to_13(isbn10)

      thirteenDigit,tenDigit = StdNum::ISBN.allNormalizedValues(issn)
        # => array of the ten and thirteen digit isbns if valid;
        #    an empty array if not

      digit = StdNum::ISBN.checkdigit(rawisbn)
        # => '0'..'9' (for isbn13) or '0'..'9','X' (for isbn10)

      digit = StdNum::ISBN.checkdigit(StdNum::ISBN.normalize(rawisbn))
        # => '0'..'9', the checkdigit of the 13-digit ISBN

      if StdNum::ISBN.valid?(rawisbn)
        puts "#{isbn} has a valid checkdigit"
      end

~~~~~

# ISSN

For an ISSN, normalization simply cleans up any extraneous characters,
uppercases the final 'X' if need be, validates, and returns.

~~~~~

      issn = StdNum::ISSN.normalize(rawissn)
      #  => the cleaned-up issn if valid; nil if not

      digit = StdNum::ISSN.checkdigit(rawissn)
      #  => '0'..'9' or 'X'

      if StdNum::ISSN.valid?(rawissn)
        puts "#{issn} has a valid checkdigit"
      end
~~~~~

# LCCN

LCCNs are normalized according to the algorithm at
http://www.loc.gov/marc/lccn-namespace.html#syntax . Normalization involves
that full process; validation includes checks on the syntax only since
there's no checkdigit.

rawlccn may be a standalone LCCN as found in a record, or a URI of the form
'http://lccn.loc.gov/89001234 .

~~~~~


    lccn = StdNum::LCCN.normalize(rawlccn)
    #  => either the normalized lccn, or nil if it has bad syntax

    if StdNum::LCCN.valid?(rawlccn) {
      puts "#{rawlccn} is valid"
    }


~~~~~


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
