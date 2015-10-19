require_relative "setup.rb"

$compound_uri = "https://mr-test.in-silico.ch/compound"
$compound = ["1S/C6H6/c1-2-4-6-5-3-1/h1-6H"]

class CompoundTest < MiniTest::Test

  def test_00_get_inchi
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "chemical/x-inchi"}
    assert_equal res.code, 200

  end

end
