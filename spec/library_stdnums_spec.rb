require 'spec_helper'

describe "Extract" do
  it "should leave a number alone" do
    StdNum.extractNumber('123456').should.equal '123456'
  end
  
  it "should skip leading and trailing crap" do
    StdNum.extractNumber(' 12345 (online)').should.equal '12345'
  end
  
  it "should allow hyphens" do
    StdNum.extractNumber(' 1-234-5').should.equal '12345'
  end
  
  it "should return nil on a non-match" do
    StdNum.extractNumber('bill dueber').should.equal nil
  end
  
  it "should allow a trailing X" do 
    StdNum.extractNumber('1-234-5-X').should.equal '12345X'
  end
  
  it "should upcase any trailing X" do
    StdNum.extractNumber('1-234-x').should.equal '1234X'
  end
  
  it "only allows a single trailing X" do
    StdNum.extractNumber('1234-X-X').should.equal '1234X'
  end
  
end


describe "ISBN" do
  it "computes 10-digit checksum" do
    StdNum::ISBN.checkdigit('0-306-40615-X').should.equal '2'
  end
  
  it "correctly uses X for checksum" do
    StdNum::ISBN.checkdigit('061871460X').should.equal 'X'
  end
  
  it "finds a zero checkdigit" do
    StdNum::ISBN.checkdigit('0139381430').should.equal '0'
  end
  
  it "computes 13-digit checksum" do
    StdNum::ISBN.checkdigit('9780306406157').should.equal '7'
  end
  
  it "finds a good number valid" do
    StdNum::ISBN.valid?('9780306406157').should.equal true
  end
  
  it "finds a bad number false" do
    StdNum::ISBN.valid?('9780306406154').should.equal false
  end
  
  it "returns nil when computing checksum for bad ISBN" do
    StdNum::ISBN.checkdigit('12345').should.equal nil
  end
  
  it "converts 10 to 13" do
    StdNum::ISBN.convert_to_13('0-306-40615-2').should.equal '9780306406157'
  end
  
  it "passes through 13 digit number instead of converting to 13" do
    StdNum::ISBN.convert_to_13('9780306406157').should.equal '9780306406157'
  end
  
  it "converts 13 to 10" do 
    StdNum::ISBN.convert_to_10('978-0-306-40615-7').should.equal '0306406152'
  end
  
end



describe 'ISSN' do
  it "computes checksum" do 
    StdNum::ISSN.checkdigit('0378-5955').should.equal '5'
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
    " 79139101 /AC/r932" => "79139101"
  }
  
  test.each do |k, v|
    it "normalizes #{k}" do
      StdNum::LCCN.normalize(k.dup).should.equal v
    end
  end
  
    
end
