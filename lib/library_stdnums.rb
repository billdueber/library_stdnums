module StdNum
  
  STDNUMPAT = /^.*?(\d[\d\-]+[xX]?)/
  
  # Extract the most likely looking number from the string. This will be the first
  # string of digits-and-hyphens-and-maybe-a-trailing-X, with the hypens removed
  def self.extractNumber str
    match = STDNUMPAT.match str
    return nil unless match
    return match[1].gsub(/\-/, '').upcase
  end
    


  module ISBN
  
    # Compute check digits for 10 or 13-digit ISBNs. See algorithm at
    # http://en.wikipedia.org/wiki/International_Standard_Book_Number
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @return [String] the one-character checkdigit
    def self.checkdigit isbn
      isbn = StdNum.extractNumber isbn
      size = isbn.size
      return nil unless size == 10 or size == 13
      checkdigit = 0
      if size == 10
        digits = isbn[0..8].split(//).map {|i| i.to_i}
        (1..9).each do |i|
          checkdigit += digits[i-1] * i
        end
        checkdigit = checkdigit % 11
        return 'X' if checkdigit == 10
        return checkdigit.to_s
      else # size == 13
        digits = isbn[0..11].split(//).map {|i| i.to_i}
        6.times do
          checkdigit += digits.shift
          checkdigit += digits.shift * 3
        end
        return (10 - (checkdigit % 10)).to_s
      end
    end
    
    # Check to see if the checkdigit is correct
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @return [Boolean] Whether or not the checkdigit is correct
    def self.valid? isbn
      isbn = StdNum.extractNumber isbn
      size = isbn.size
      return false unless (size == 10 or size == 13)
      return isbn[-1..-1] == self.checkdigit(isbn)
    end
  
    # To convert to an ISBN13, throw a '978' on the front and 
    # compute the checkdigit
    # We leave 13-digit numbers alone, figuring they're already ok,
    # and return nil on anything that's not the right length
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @return [String] The converted 13-character ISBN, nil if something looks wrong, or whatever was passed in if it already looked like a 13-digit ISBN
    def self.convert_to_13 isbn
      isbn = StdNum.extractNumber isbn
      size = isbn.size
      return isbn if size == 13
      return nil unless size == 10
    
      prefix = '978' + isbn[0..8]
      return prefix + self.checkdigit(prefix + '0')
    end
    
    
    # Convert to 10 if it's 13 digits and the first three digits are 978.
    # Pass through anything 10-digits, and return nil for everything else.
    # @param [String] isbn The ISBN (we'll try to clean it up if possible)
    # @return [String] The converted 10-character ISBN, nil if something looks wrong, or whatever was passed in if it already looked like a 10-digit ISBN
    def self.convert_to_10 isbn
      isbn = StdNum.extractNumber isbn
      size = isbn.size
      return isbn if size == 10
      return nil unless size == 13
      return nil unless isbn[0..2] == '978'
      
      prefix = isbn[3..11]
      return prefix + self.checkdigit(prefix + '0')
    end
    
    # Return an array of the ISBN10 and ISBN13 for the passed in value. You'll
    # only get one value back if it's a 13-digit
    # ISBN that can't be converted to an ISBN10.
    # @param [String] isbn The original ISBN, in 10-character or 13-digit format
    # @return [Array] Either the (one or two) normalized ISBNs, or an empty array if
    # it can't be recognized.
    
    def self.allNormalizedValues isbn
      isbn = StdNum.extractNumber isbn
      case isbn.size
      when 10
        return [isbn, self.convert_to_13(isbn)]
      when 13
        return [isbn, self.convert_to_10(isbn)].compact
      else
        return []
      end
    end
    
    
  end
  
  module ISSN
    
    # Compute the checkdigit of an ISSN
    # @param [String] issn The ISSN (we'll try to clean it up if possible)
    # @return [String] the one-character checkdigit
    def self.checkdigit issn
      issn = StdNum.extractNumber issn
      return nil unless issn.size == 8
      digits = issn[0..6].split(//).map {|i| i.to_i}
      checkdigit = 0
      (0..6).each do |i|
        checkdigit += digits[i] * (8 - i) 
      end
      checkdigit = checkdigit % 11
      return 0 if checkdigit == 0
      checkdigit = 11 - checkdigit
      return 'X' if checkdigit == 10
      return checkdigit.to_s
    end
      
    
  end
  
  module LCCN
    # Normalize based on data at http://www.loc.gov/marc/lccn-namespace.html#syntax
    # @param [String] str The LCCN to normalize
    # @return [String] the normalized LCCN, or nil if it looks malformed
    def self.normalize str
      str.gsub!(/\s/, '')
      str.gsub!(/\/.*$/, '')
      if str =~ /^(.*?)\-(.+)/
        pre =  $1
        post = $2
        return nil unless post =~ /^\d+$/ # must be all digits
        return "%s%06d" % [pre, post]
      end
      return str
    end
  end  
  
  
end
      
    