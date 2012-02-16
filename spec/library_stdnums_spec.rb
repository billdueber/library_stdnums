require 'spec_helper'

describe "Extract" do
  it "should leave a number alone" do
    StdNum::ISBN.extractNumber('1234567').must_equal '1234567'
  end

  it "should skip leading and trailing crap" do
    StdNum::ISBN.extractNumber(' 1234567 (online)').must_equal '1234567'
  end

  it "should allow hyphens" do
    StdNum::ISBN.extractNumber(' 1-234-5').must_equal '12345'
  end

  it "should return nil on a non-match" do
    StdNum::ISBN.extractNumber('bill dueber').must_equal nil
  end

  it "should allow a trailing X" do
    StdNum::ISBN.extractNumber('1-234-5-X').must_equal '12345X'
  end

  it "should upcase any trailing X" do
    StdNum::ISBN.extractNumber('1-234-56-x').must_equal '123456X'
  end

  it "only allows a single trailing X" do
    StdNum::ISBN.extractNumber('123456-X-X').must_equal '123456X'
  end

  it "doesn't allow numbers that are too short" do
    StdNum::ISBN.extractNumber('12345').must_equal nil
  end

  it "skips over short prefixing numbers" do
    StdNum::ISBN.extractNumber('ISBN13: 1234567890123').must_equal '1234567890123'
  end

end


describe "ISBN" do
  it "computes 10-digit checksum" do
    StdNum::ISBN.checkdigit('0-306-40615-X').must_equal '2'
  end

  it "correctly uses X for checksum" do
    StdNum::ISBN.checkdigit('061871460X').must_equal 'X'
  end

  it "finds a zero checkdigit" do
    StdNum::ISBN.checkdigit('0139381430').must_equal '0'
  end

  it "computes 13-digit checksum" do
    StdNum::ISBN.checkdigit('9780306406157').must_equal '7'
  end

  it "computes a 13-digit checksum that is 0" do
    StdNum::ISBN.checkdigit('9783837612950').must_equal '0'
  end

  it "finds a good number valid" do
    StdNum::ISBN.valid?('9780306406157').must_equal true
  end

  it "finds a bad number invalid" do
    StdNum::ISBN.valid?('9780306406154').must_equal false
  end

  it "returns nil when computing checksum for bad ISBN" do
    StdNum::ISBN.checkdigit('12345').must_equal nil
  end

  it "converts 10 to 13" do
    StdNum::ISBN.convert_to_13('0-306-40615-2').must_equal '9780306406157'
  end

  it "passes through 13 digit number instead of converting to 13" do
    StdNum::ISBN.convert_to_13('9780306406157').must_equal '9780306406157'
  end

  it "converts 13 to 10" do
    StdNum::ISBN.convert_to_10('978-0-306-40615-7').must_equal '0306406152'
  end

  it "gets both normalized values" do
    a = StdNum::ISBN.allNormalizedValues('978-0-306-40615-7')
    a.sort.must_equal ['9780306406157', '0306406152' ].sort
  end



end



describe 'ISSN' do
  it "computes checksum" do
    StdNum::ISSN.checkdigit('0378-5955').must_equal '5'
  end

  it "normalizes" do
    StdNum::ISSN.normalize('0378-5955').must_equal '03785955'
  end
end


describe 'LCCN' do

  # Tests take from http://www.loc.gov/marc/lccn-namespace.html#syntax
  test = {
    "n78-890351" => "n78890351",
    "n78-89035" => "n78089035",
    "n 78890351 " => "n78890351",
    " 85000002 " => "85000002",
    "85-2 " => "85000002",
    "2001-000002" => "2001000002",
    "75-425165//r75" => "75425165",
    " 79139101 /AC/r932" => "79139101",
  }

  test.each do |k, v|
    it "normalizes #{k}" do
      StdNum::LCCN.normalize(k.dup).must_equal v
    end
  end


end
