require_relative "setup.rb"


class ModelTest < MiniTest::Test

  def test_0_get_urilist
    res = RestClientWrapper.get $model_uri,,{:Accept => "text/uri-list"}
    assert_equal res.code, 200
  end

  def test_0_get_notsupported
    res = RestClientWrapper.get $model_uri,,{:Accept => "text/notimplemented-type"}
    assert_equal res.code, 400
  end


end