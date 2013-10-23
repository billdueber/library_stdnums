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
  
  it "says a good number is trying" do
    StdNum::ISBN.at_least_trying?('9780306406157').must_equal true
  end
  
  it "says bad data is not trying" do
    StdNum::ISBN.at_least_trying?('978006406157').must_equal false
    StdNum::ISBN.at_least_trying?('406157').must_equal false
    StdNum::ISBN.at_least_trying?('$22').must_equal false
    StdNum::ISBN.at_least_trying?('hello').must_equal false
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

  it "normalizes" do
    StdNum::ISBN.normalize('0-306-40615-2').must_equal '9780306406157'
    StdNum::ISBN.normalize('0-306-40615-X').must_equal nil
    StdNum::ISBN.normalize('ISBN: 978-0-306-40615-7').must_equal '9780306406157'
    StdNum::ISBN.normalize('ISBN: 978-0-306-40615-3').must_equal nil
  end

  it "gets both normalized values" do
    a = StdNum::ISBN.allNormalizedValues('978-0-306-40615-7')
    a.sort.must_equal ['9780306406157', '0306406152' ].sort

    a = StdNum::ISBN.allNormalizedValues('0-306-40615-2')
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


describe 'LCCN basics' do

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

  it "validates correctly" do
    StdNum::LCCN.valid?("n78-890351").must_equal true
    StdNum::LCCN.valid?("n78-89035100444").must_equal false, "Too long"
    StdNum::LCCN.valid?("n78").must_equal false, "Too short"
    StdNum::LCCN.valid?("na078-890351").must_equal false, "naa78-890351 should start with three letters or digits"
    StdNum::LCCN.valid?("n078-890351").must_equal false, "n078-890351 should start with two letters or two digits"
    StdNum::LCCN.valid?("na078-890351").must_equal false, "na078-890351 should start with three letters or digits"
    StdNum::LCCN.valid?("0an78-890351").must_equal false, "0an78-890351 should start with three letters or digits"
    StdNum::LCCN.valid?("n78-89c0351").must_equal false, "n78-89c0351 has a letter after the dash"
  end


end


describe "LCCN tests from Business::LCCN perl module" do
  tests = [
    {  :orig => 'n78-890351',
                 :canonical => 'n  78890351 ',
                 :normalized => 'n78890351',
                 :prefix => 'n',
                 :year_cataloged => 1978,
                 :serial => '890351',
              },
              {  :orig => 'n 78890351 ',
                 :canonical => 'n  78890351 ',
                 :normalized => 'n78890351',
                 :prefix => 'n',
                 :year_cataloged => 1978,
                 :serial => '890351',
              },
              {  :orig => ' 85000002 ',
                 :canonical => '   85000002 ',
                 :normalized => '85000002',
                 :year_cataloged => 1985,
                 :serial => '000002',
              },
              {  :orig => '85-2 ',
                 :canonical => '   85000002 ',
                 :normalized => '85000002',
                 :year_cataloged => 1985,
                 :serial => '000002',
              },
              {  :orig => '2001-000002',
                 :canonical => '  2001000002',
                 :normalized => '2001000002',
                 :year_cataloged => 2001,
                 :serial => '000002',
              },
              {  :orig => '75-425165//r75',
                 :canonical => '   75425165 //r75',
                 :normalized => '75425165',
                 :prefix => '',
                 :year_cataloged => nil,
                 :serial => '425165',
                 :revision_year => 1975,
                 :revision_year_encoded => '75',
                 :revision_number => nil,
              },
              {  :orig => ' 79139101 /AC/r932',
                 :canonical => '   79139101 /AC/r932',
                 :normalized => '79139101',
                 :prefix => '',
                 :year_cataloged => nil,
                 :serial => '139101',
                 :suffix_encoded => '/AC',
                 :revision_year => 1993,
                 :revision_year_encoded => '93',
                 :revision_number => 2,
              },
              {  :orig => '89-4',
                 :canonical => '   89000004 ',
                 :normalized => '89000004',
                 :year_cataloged => 1989,
                 :serial => '000004',
              },
              {  :orig => '89-45',
                 :canonical => '   89000045 ',
                 :normalized => '89000045',
                 :year_cataloged => 1989,
                 :serial => '000045',
              },
              {  :orig => '89-456',
                 :canonical => '   89000456 ',
                 :normalized => '89000456',
                 :year_cataloged => 1989,
                 :serial => '000456',
              },
              {  :orig => '89-1234',
                 :canonical => '   89001234 ',
                 :normalized => '89001234',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => '89-001234',
                 :canonical => '   89001234 ',
                 :normalized => '89001234',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => '89001234',
                 :canonical => '   89001234 ',
                 :normalized => '89001234',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => '2002-1234',
                 :canonical => '  2002001234',
                 :normalized => '2002001234',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => '2002-001234',
                 :canonical => '  2002001234',
                 :normalized => '2002001234',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => '2002001234',
                 :canonical => '  2002001234',
                 :normalized => '2002001234',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => '   89001234 ',
                 :canonical => '   89001234 ',
                 :normalized => '89001234',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => '  2002001234',
                 :canonical => '  2002001234',
                 :normalized => '2002001234',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'a89-1234',
                 :canonical => 'a  89001234 ',
                 :normalized => 'a89001234',
                 :prefix => 'a',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'a89-001234',
                 :canonical => 'a  89001234 ',
                 :normalized => 'a89001234',
                 :prefix => 'a',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'a89001234',
                 :canonical => 'a  89001234 ',
                 :normalized => 'a89001234',
                 :prefix => 'a',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'a2002-1234',
                 :canonical => 'a 2002001234',
                 :normalized => 'a2002001234',
                 :prefix => 'a',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'a2002-001234',
                 :canonical => 'a 2002001234',
                 :normalized => 'a2002001234',
                 :prefix => 'a',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'a2002001234',
                 :canonical => 'a 2002001234',
                 :normalized => 'a2002001234',
                 :prefix => 'a',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'a 89001234 ',
                 :canonical => 'a  89001234 ',
                 :normalized => 'a89001234',
                 :prefix => 'a',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'a 89-001234 ',
                 :canonical => 'a  89001234 ',
                 :normalized => 'a89001234',
                 :prefix => 'a',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'a 2002001234',
                 :canonical => 'a 2002001234',
                 :normalized => 'a2002001234',
                 :prefix => 'a',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'ab89-1234',
                 :canonical => 'ab 89001234 ',
                 :normalized => 'ab89001234',
                 :prefix => 'ab',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'ab89-001234',
                 :canonical => 'ab 89001234 ',
                 :normalized => 'ab89001234',
                 :prefix => 'ab',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'ab89001234',
                 :canonical => 'ab 89001234 ',
                 :normalized => 'ab89001234',
                 :prefix => 'ab',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'ab2002-1234',
                 :canonical => 'ab2002001234',
                 :normalized => 'ab2002001234',
                 :prefix => 'ab',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'ab2002-001234',
                 :canonical => 'ab2002001234',
                 :normalized => 'ab2002001234',
                 :prefix => 'ab',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'ab2002001234',
                 :canonical => 'ab2002001234',
                 :normalized => 'ab2002001234',
                 :prefix => 'ab',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'ab 89001234 ',
                 :canonical => 'ab 89001234 ',
                 :normalized => 'ab89001234',
                 :prefix => 'ab',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'ab 2002001234',
                 :canonical => 'ab2002001234',
                 :normalized => 'ab2002001234',
                 :prefix => 'ab',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'ab 89-1234',
                 :canonical => 'ab 89001234 ',
                 :normalized => 'ab89001234',
                 :prefix => 'ab',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'abc89-1234',
                 :canonical => 'abc89001234 ',
                 :normalized => 'abc89001234',
                 :prefix => 'abc',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'abc89-001234',
                 :canonical => 'abc89001234 ',
                 :normalized => 'abc89001234',
                 :prefix => 'abc',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'abc89001234',
                 :canonical => 'abc89001234 ',
                 :normalized => 'abc89001234',
                 :prefix => 'abc',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'abc89001234 ',
                 :canonical => 'abc89001234 ',
                 :normalized => 'abc89001234',
                 :prefix => 'abc',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/89001234',
                 :canonical => '   89001234 ',
                 :normalized => '89001234',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/a89001234',
                 :canonical => 'a  89001234 ',
                 :normalized => 'a89001234',
                 :serial => '001234',
                 :prefix => 'a',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/ab89001234',
                 :canonical => 'ab 89001234 ',
                 :normalized => 'ab89001234',
                 :prefix => 'ab',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/abc89001234',
                 :canonical => 'abc89001234 ',
                 :normalized => 'abc89001234',
                 :prefix => 'abc',
                 :year_cataloged => 1989,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/2002001234',
                 :canonical => '  2002001234',
                 :normalized => '2002001234',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/a2002001234',
                 :canonical => 'a 2002001234',
                 :normalized => 'a2002001234',
                 :prefix => 'a',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => 'http://lccn.loc.gov/ab2002001234',
                 :canonical => 'ab2002001234',
                 :normalized => 'ab2002001234',
                 :prefix => 'ab',
                 :year_cataloged => 2002,
                 :serial => '001234',
              },
              {  :orig => '00-21595',
                 :canonical => '   00021595 ',
                 :normalized => '00021595',
                 :year_cataloged => 2000,
                 :serial => '021595',
              },
              {  :orig => '2001001599',
                 :canonical => '  2001001599',
                 :normalized => '2001001599',
                 :year_cataloged => 2001,
                 :serial => '001599',
              },
              {  :orig => '99-18233',
                 :canonical => '   99018233 ',
                 :normalized => '99018233',
                 :year_cataloged => 1999,
                 :serial => '018233',
              },
              {  :orig => '98000595',
                 :canonical => '   98000595 ',
                 :normalized => '98000595',
                 :year_cataloged => 1898,
                 :serial => '000595',
              },
              {  :orig => '99005074',
                 :canonical => '   99005074 ',
                 :normalized => '99005074',
                 :year_cataloged => 1899,
                 :serial => '005074',
              },
              {  :orig => '00003373',
                 :canonical => '   00003373 ',
                 :normalized => '00003373',
                 :year_cataloged => 1900,
                 :serial => '003373',
              },
              {  :orig => '01001599',
                 :canonical => '   01001599 ',
                 :normalized => '01001599',
                 :year_cataloged => 1901,
                 :serial => '001599',
              },
              {  :orig => '   95156543 ',
                 :canonical => '   95156543 ',
                 :normalized => '95156543',
                 :year_cataloged => 1995,
                 :serial => '156543',
              },
              {  :orig => '   94014580 /AC/r95',
                 :canonical => '   94014580 /AC/r95',
                 :normalized => '94014580',
                 :year_cataloged => 1994,
                 :serial => '014580',
                 :suffix_encoded => '/AC',
                 :revision_year_encoded => '95',
                 :revision_year => 1995,
              },
              {  :orig => '   79310919 //r86',
                 :canonical => '   79310919 //r86',
                 :normalized => '79310919',
                 :year_cataloged => 1979,
                 :serial => '310919',
                 :revision_year_encoded => '86',
                 :revision_year => 1986,
              },
              {  :orig => 'gm 71005810  ',
                 :canonical => 'gm 71005810 ',
                 :normalized => 'gm71005810',
                 :prefix => 'gm',
                 :year_cataloged => 1971,
                 :serial => '005810',
              },
              {  :orig => 'sn2006058112  ',
                 :canonical => 'sn2006058112',
                 :normalized => 'sn2006058112',
                 :prefix => 'sn',
                 :year_cataloged => 2006,
                 :serial => '058112',
              },
              {  :orig => 'gm 71-2450',
                 :canonical => 'gm 71002450 ',
                 :normalized => 'gm71002450',
                 :prefix => 'gm',
                 :year_cataloged => 1971,
                 :serial => '002450',
              },
              {  :orig => '2001-1114',
                 :canonical => '  2001001114',
                 :normalized => '2001001114',
                 :year_cataloged => 2001,
                 :serial => '001114',
              },
  ]
  tests.each do |h|
    it "normalizes #{h[:orig]}" do
      StdNum::LCCN.normalize(h[:orig]).must_equal h[:normalized], "#{h[:orig]} doesn't normalize to #{h[:normalized]}"
    end
  end
end

