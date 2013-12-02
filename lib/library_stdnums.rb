# Static Module functions to work with library "standard numbers" ISSN, ISBN, and LCCN
module StdNum

  # Helper methods common to ISBN/ISSN
  module Helpers

    # The pattern we use to try and find an ISBN/ISSN. Ditch everthing before the first
    # digit, then take all the digits/hyphens, optionally followed by an 'X'
    # Since the shortest possible string is 7 digits followed by a checksum digit
    # for an ISSN, we'll make sure they're at least that long. Still imperfect
    # (would fine "5------", for example) but should work in most cases.
    STDNUMPAT = /^.*?(\d[\d\-]{6,}[xX]?)/

    # Extract the most likely looking number from the string. This will be the first
    # string of digits-and-hyphens-and-maybe-a-trailing-X, with the hypens removed
    # @param [String] str The string from which to extract an ISBN/ISSN
    # @return [String] The extracted identifier
    def extractNumber str
      match = STDNUMPAT.match str
      return nil unless match
      return (match[1].gsub(/\-/, '')).upcase
    end

    # Given any string, extract what looks like the most likely ISBN/ISSN
    # of the given size(s), or nil if nothing matches at the correct size.
    # @param [String] rawnum The raw string containing (hopefully) an ISSN/ISBN
    # @param [Integer, Array<Integer>, nil] valid_sizes An integer or array of integers of valid sizes
    # for this type (e.g., 10 or 13 for ISBN, 8 for ISSN)
    # @return [String,nil] the reduced and verified number, or nil if there's no match at the right size
    def reduce_to_basics rawnum, valid_sizes = nil
      return nil if rawnum.nil?

      num = extractNumber rawnum

      # Does it even look like a number?
      return nil unless num

      # Return what we've got if we don't care about the size
      return num unless valid_sizes

      # Check for valid size(s)
      [valid_sizes].flatten.each do |s|
        return num if num.size == s
      end

      # Didn't check out size-wise. Return nil
      return nil
    end
  end

  # Validate, convert, and normalize ISBNs (10-digit or 13-digit)
  module ISBN
    extend Helpers
    
    # Does it even look like an ISBN?
    def self.at_least_trying? isbn
      reduce_to_basics(isbn, [10,13]) ? true : false
    end
    

    # Compute check digits for 10 or 13-digit ISBNs. See algorithm at
    # http://en.wikipedia.org/wiki/International_Standard_Book_Number
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @param [Boolean] preprocessed Set to true if the ISBN has already been through reduce_to_basics
    # @return [String,nil] the one-character checkdigit, or nil if it's not an ISBN string
    def self.checkdigit isbn, preprocessed = false
      isbn = reduce_to_basics isbn, [10,13] unless preprocessed
      return nil unless isbn

      checkdigit = 0
      if isbn.size == 10
        digits = isbn[0..8].split(//).map {|i| i.to_i}
        (1..9).each do |i|
          checkdigit += digits[i-1] * i
        end
        checkdigit = checkdigit % 11
        return 'X' if checkdigit == 10
        return checkdigit.to_s
      else # size == 13
        checkdigit = 0
        digits = isbn[0..11].split(//).map {|i| i.to_i}
        6.times do
          checkdigit += digits.shift
          checkdigit += digits.shift * 3
        end
        check = 10 - (checkdigit % 10)
        check = 0 if check == 10
        return check.to_s
      end
    end

    # Check to see if the checkdigit is correct
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @param [Boolean] preprocessed Set to true if the ISBN has already been through reduce_to_basics
    # @return [Boolean] Whether or not the checkdigit is correct. Sneakily, return 'nil' for 
    #  values that don't even look like ISBNs, and 'false' for those that look possible but
    #  don't normalize / have bad checkdigits
    def self.valid? isbn, preprocessed = false
      return nil if isbn.nil?
      isbn = reduce_to_basics(isbn, [10,13]) unless preprocessed
      return nil unless isbn
      return false unless isbn[-1..-1] == self.checkdigit(isbn, true)
      return true
    end


    # For an ISBN, normalizing it is the same as converting to ISBN 13
    # and making sure it's valid
    #
    # @param [String] rawisbn The ISBN to normalize
    # @return [String, nil] the normalized (to 13 digit) ISBN, or nil on failure
    def self.normalize rawisbn
      isbn = convert_to_13 rawisbn
      if isbn
        return isbn
      else
        return nil
      end
    end

    # To convert to an ISBN13, throw a '978' on the front and
    # compute the checkdigit
    # We leave 13-digit numbers alone, figuring they're already ok. NO CHECKSUM CHECK IS DONE FOR 13-DIGIT ISBNS!
    # and return nil on anything that's not the right length
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @return [String, nil] The converted 13-character ISBN, nil if something looks wrong, or whatever was passed in if it already looked like a 13-digit ISBN
    def self.convert_to_13 isbn
      isbn = reduce_to_basics isbn, [10,13]
      return nil unless isbn
      return nil unless valid?(isbn, true)
      return isbn if isbn.size == 13
      prefix = '978' + isbn[0..8]
      return prefix + self.checkdigit(prefix + '0', true)
    end


    # Convert to 10 if it's 13 digits and the first three digits are 978.
    # Pass through anything 10-digits, and return nil for everything else.
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @return [String] The converted 10-character ISBN, nil if something looks wrong, or whatever was passed in if it already looked like a 10-digit ISBN
    def self.convert_to_10 isbn
      isbn = reduce_to_basics isbn, [10,13]

      # Already 10 digits? Just return
      return isbn if isbn.size == 10

      # Can't be converted to ISBN-10? Bail
      return nil unless isbn[0..2] == '978'

      prefix = isbn[3..11]
      return prefix + self.checkdigit(prefix + '0')
    end

    # Return an array of the ISBN13 and ISBN10 (in that order) for the passed in value. You'll
    # only get one value back if it's a 13-digit
    # ISBN that can't be converted to an ISBN10.
    # @param [String] isbn The original ISBN, in 10-character or 13-digit format
    # @return [Array<String,String>, nil] Either the (one or two) normalized ISBNs, or nil if
    # it can't be recognized.
    #
    # @example Get the normalized values and index them (if valid) or original value (if not)
    #   norms = StdNum::ISBN.allNormalizedValues(rawisbn)
    #   doc['isbn'] = norms ? norms : [rawisbn]
    def self.allNormalizedValues isbn
      isbn = reduce_to_basics isbn, [10,13]
      return [] unless isbn
      case isbn.size
      when 10
        return [self.convert_to_13(isbn), isbn]
      when 13
        return [isbn, self.convert_to_10(isbn)].compact
      end
    end


  end

  # Validate and and normalize ISSNs
  module ISSN
    extend Helpers


    # Does it even look like an ISSN?
    def self.at_least_trying? issn
      return !(reduce_to_basics(issn, 8))
    end


    # Compute the checkdigit of an ISSN
    # @param [String] issn The ISSN (we'll try to clean it up if possible)
    # @param [Boolean] preprocessed Set to true if the number has already been through reduce_to_basic
    # @return [String] the one-character checkdigit

    def self.checkdigit issn, preprocessed = false
      issn = reduce_to_basics issn, 8 unless preprocessed
      return nil unless issn

      digits = issn[0..6].split(//).map {|i| i.to_i}
      checkdigit = 0
      (0..6).each do |i|
        checkdigit += digits[i] * (8 - i)
      end
      checkdigit = checkdigit % 11
      return '0' if checkdigit == 0
      checkdigit = 11 - checkdigit
      return 'X' if checkdigit == 10
      return checkdigit.to_s
    end

    # Check to see if the checkdigit is correct
    # @param [String] issn The ISSN (we'll try to clean it up if possible)
    # @param [Boolean] preprocessed Set to true if the number has already been through reduce_to_basic
    # @return [Boolean] Whether or not the checkdigit is correct. Sneakily, return 'nil' for 
    #  values that don't even look like ISBNs, and 'false' for those that look possible but
    #  don't normalize / have bad checkdigits

    def self.valid? issn, preprocessed = false
      issn = reduce_to_basics issn, 8 unless preprocessed
      return nil unless issn
      return issn[-1..-1] == self.checkdigit(issn, true)
    end



    # Make sure it's valid, remove the dashes, uppercase the X, and return
    # @param [String] rawissn The ISSN to normalize
    # @return [String, nil] the normalized ISSN, or nil on failure
    def self.normalize rawissn
      issn = reduce_to_basics rawissn, 8
      if issn and valid?(issn, true)
        return issn
      else
        return nil
      end
    end



  end

  # Validate and and normalize LCCNs
  module LCCN


    # Get a string ready for processing as an LCCN
    # @param [String] str The possible lccn
    # @return [String] The munged string, ready for normalization

    def self.reduce_to_basic str
      rv = str.gsub(/\s/, '')  # ditch spaces
      rv.gsub!('http://lccn.loc.gov/', '') # remove URI prefix
      rv.gsub!(/\/.*$/, '') # ditch everything after the first '/' (including the slash)
      return rv
    end

    # Normalize based on data at http://www.loc.gov/marc/lccn-namespace.html#syntax
    # @param [String] rawlccn The possible LCCN to normalize
    # @return [String, nil] the normalized LCCN, or nil if it looks malformed
    def self.normalize rawlccn
      lccn = reduce_to_basic(rawlccn)
      # If there's a dash in it, deal with that.
      if lccn =~ /^(.*?)\-(.+)/
        pre =  $1
        post = $2
        return nil unless post =~ /^\d+$/ # must be all digits
        lccn = "%s%06d" % [pre, post.to_i]
      end

      if valid?(lccn, true)
        return lccn
      else
        return nil
      end
    end

    # The rules for validity according to http://www.loc.gov/marc/lccn-namespace.html#syntax:
    #
    # A normalized LCCN is a character string eight to twelve characters in length. (For purposes of this description characters are ordered from left to right -- "first" means "leftmost".)
    # The rightmost eight characters are always digits.
    # If the length is 9, then the first character must be alphabetic.
    # If the length is 10, then the first two characters must be either both digits or both alphabetic.
    # If the length is 11, then the first character must be alphabetic and the next two characters must be either both digits or both alphabetic.
    # If the length is 12, then the first two characters must be alphabetic and the remaining characters digits.
    #
    # @param [String] lccn The lccn to attempt to validate
    # @param [Boolean] preprocessed Set to true if the number has already been normalized
    # @return [Boolean] Whether or not the syntax seems ok

    def self.valid? lccn, preprocessed = false
      lccn = normalize(lccn) unless preprocessed
      return false unless lccn
      clean = lccn.gsub(/\-/, '')
      suffix = clean[-8..-1] # "the rightmost eight characters are always digits"
      return false unless suffix and suffix =~ /^\d+$/
      case clean.size # "...is a character string eight to twelve digits in length"
      when 8
        return true
      when 9
        return true if clean =~ /^[A-Za-z]/
      when 10
        return true if clean =~ /^\d{2}/ or clean =~ /^[A-Za-z]{2}/
      when 11
        return true if clean =~ /^[A-Za-z](\d{2}|[A-Za-z]{2})/
      when 12
        return true if clean =~ /^[A-Za-z]{2}\d{2}/
      else
        return false
      end

      return false
    end

  end

end

