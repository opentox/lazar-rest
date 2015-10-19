require_relative "setup.rb"

$compound_uri = "https://mr-test.in-silico.ch/compound"
$compound = ["1S/C6H6/c1-2-4-6-5-3-1/h1-6H"]

class CompoundTest < MiniTest::Test

  def test_00_get_inchi
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "chemical/x-inchi"}
    assert_equal res.code, 200
    assert_equal res, "InChI=1S/C6H6/c1-2-4-6-5-3-1/h1-6H"
  end

  def test_01_get_smiles
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "chemical/x-daylight-smiles"}
    assert_equal res.code, 200
    assert_equal res, "c1ccccc1"
  end

  def test_02_get_sdf
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "chemical/x-mdl-sdfile"}
    assert_equal res.code, 200
    assert res.include?("OpenBabel10191511303D")
  end

  def test_03_get_png
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "image/png"}
    assert_equal res.code, 200
    assert_equal "image/png", res.headers[:content_type]
  end

  def test_04_get_svg
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "image/svg+xml"}
    assert_equal res.code, 200
    assert res.include?("<svg version=")
  end

  def test_05_get_json
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "application/json"}
    assert_equal res.code, 200
    assert res.include?("{\"_id\":{\"$oid\":")
    js = JSON.parse res
    assert_equal js["chemblid"], "CHEMBL581676"
  end

  def test_06_get_names
    res = RestClientWrapper.get File.join($compound_uri, $compound[0]), {}, {:accept => "text/plain"}
    assert_equal res.code, 200
    assert res.include?("Benzene")
    assert res.include?("401765_ALDRICH")
  end

end
