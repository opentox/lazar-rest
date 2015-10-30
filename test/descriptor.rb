require_relative "setup.rb"

$host = "https://mr-test.in-silico.ch"


class DescriptorTest < MiniTest::Test

  def test_00_get_descriptors
    res = RestClientWrapper.get File.join($host, "algorithm/descriptor"), {}, {:accept => "text/plain"}
    assert_equal res.code, 200
    assert res.include?("Joelib.KierShape1: no description available\nJoelib.KierShape2: no description available")
  end


end