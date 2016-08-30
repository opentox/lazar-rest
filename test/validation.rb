require_relative "setup.rb"

$validation_uri = "#{$host}/validation"
class ModelTest < MiniTest::Test

  def test_00_get_urilist
    res = RestClientWrapper.get $validation_uri, {}, {:accept => "text/uri-list"}
    assert_equal res.code, 200
  end

  def test_01_get_400
    assert_raises OpenTox::BadRequestError do
      res = OpenTox::RestClientWrapper.get $validation_uri, {}, {:accept => "text/notimplemented-type"}
    end
  end

end