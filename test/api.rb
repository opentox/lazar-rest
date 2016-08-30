require_relative "setup.rb"
$api_uri = "#{$host}/api/api.json"


class ApiTest < MiniTest::Test

  def test_0_api_get
    res = RestClientWrapper.get $api_uri
    assert_equal res.code, 200
    assert JSON.parse "#{res.body}"
  end

end
