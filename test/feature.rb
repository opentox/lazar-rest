require_relative "setup.rb"

$feature_uri = "#{$host}/feature"
class ModelTest < MiniTest::Test

  def test_00_get_urilist
    res = RestClientWrapper.get $feature_uri, {}, {:accept => "text/uri-list"}
    assert_equal res.code, 200
  end

  def test_01_get_feature
    res = RestClientWrapper.get $feature_uri, {}, {:accept => "text/uri-list"}
    feature = res.body.split("\n")[0]
    res = RestClientWrapper.get feature, {}, {:accept => "text/uri-list"}
    assert_equal res.code, 200
    res = RestClientWrapper.get feature, {}, {:accept => "application/json"}
    assert_equal res.code, 200
  end

  def test_02_get_feature
    uri = File.join($feature_uri, Feature.last.id)
    res = RestClientWrapper.get uri, {}, {:accept => "application/json"}
    json = JSON.parse(res.body)
    assert_equal Feature.last.id.to_s, json["_id"]["$oid"]
    assert_equal Feature.last.category, json["category"]
  end

  def test_01_get_400
    assert_raises OpenTox::BadRequestError do
      res = OpenTox::RestClientWrapper.get $feature_uri, {}, {:accept => "text/notimplemented-type"}
    end
  end
end
