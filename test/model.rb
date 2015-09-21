require_relative "setup.rb"

$model_uri = "https://mr-test.in-silico.ch/model"
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

  # create a model
  def test_02_create
    file = "../../lazar/test/data/hamster_carcinogenicity.csv"
    res = OpenTox::RestClientWrapper.post $model_uri, {:file => File.open(file)}, {:content_type => "text/csv"}
    assert_equal res.code, 200
    @@model = res
  end

  def test_90_delete
    res = OpenTox::RestClientWrapper.delete @@model
    assert_equal res.code, 200
    assert_raises OpenTox::NotFoundError do
      res = OpenTox::RestClientWrapper.get @@model, {}, {:accept => "application/json"}
    end

  end


end
