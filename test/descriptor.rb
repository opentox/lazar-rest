require_relative "setup.rb"

$host = "#{$host}"


class DescriptorTest < MiniTest::Test

  def test_00_get_descriptors
    result = RestClientWrapper.get File.join($host, "algorithm/descriptor"), {}, {:accept => "text/plain"}
    assert_equal result.code, 200
    assert result.include?("Joelib.KierShape1: no description available\nJoelib.KierShape2: no description available"), "Descriptor list is not complete."
    assert_equal 110, result.lines.count
  end

  def test_01_get_descriptor
    result = RestClientWrapper.get File.join($host, "algorithm/descriptor", "Openbabel.MW"), {}, {:accept => "text/plain"}
    assert_equal result.code, 200
    assert_equal result, "Molecular Weight filter"
  end

  def test_02_post_descriptor
    result = RestClientWrapper.post File.join($host, "algorithm/descriptor"), {:identifier => "CC(=O)CC(C)C#N", :descriptor => "Joelib.LogP"}, {:accept => "application/csv"}
    assert_equal result.code, 200
    assert_equal "SMILES,Joelib.LogP\nCC(=O)CC(C)C#N,2.65908\n", result
  end

  def test_03_post_descriptor_file
    file = File.join(DATA_DIR, "hamster_carcinogenicity.mini.csv")
    result = RestClientWrapper.post File.join($host, "algorithm/descriptor"), {:file => File.open(file), :descriptor => "Openbabel.logP,Cdk.AtomCount,Cdk.CarbonTypes,Joelib.LogP"}, {:accept => "application/json"}
    assert_equal result.code, 200
    proof_result = File.read(File.join(REST_DATA_DIR, "test_03_post_descriptor_file.result"))
    assert_equal result, proof_result.strip
  end

end
