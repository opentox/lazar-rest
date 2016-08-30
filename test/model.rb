require_relative "setup.rb"

$model_uri = "#{$host}/model"
class ModelTest < MiniTest::Test

  def test_00_get_urilist
    res = RestClientWrapper.get $model_uri, {}, {:accept => "text/uri-list"}
    assert_equal res.code, 200
  end

  def test_01_get_400
    assert_raises OpenTox::BadRequestError do
      res = OpenTox::RestClientWrapper.get $model_uri, {}, {:accept => "text/notimplemented-type"}
    end
  end

end
