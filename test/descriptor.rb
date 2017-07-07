require_relative "setup.rb"

$host = "#{$host}"


class DescriptorTest < MiniTest::Test

  def test_00_get_descriptors
    result = RestClientWrapper.get File.join($host, "compound/descriptor"), {}, {:accept => "text/plain"}
    assert_equal result.code, 200
    assert result.include?("Joelib.KierShape1: JOELIb does not provide meaningful descriptions, see java/JoelibDescriptors.java for details.\nJoelib.KierShape2: JOELIb does not provide meaningful descriptions, see java/JoelibDescriptors.java for details."), "Descriptor list is not complete."
    assert_equal 346, result.lines.count
  end

  def test_01_get_descriptor
    result = RestClientWrapper.get File.join($host, "compound/descriptor", "Openbabel.MW"), {}, {:accept => "text/plain"}
    assert_equal result.code, 200
    assert_equal result, "Molecular Weight filter"
  end

  def test_03_get_descriptor_id
    result = RestClientWrapper.get File.join($host, "compound/descriptor", "Openbabel.HBA1"), {}, {:accept => "application/json"}
    assert_equal result.code, 200
    json = JSON.parse(result)
    assert_equal json["description"], "Number of Hydrogen Bond Acceptors 1 (JoelLib)"
    bsonid = json["_id"]["$oid"]
    result = RestClientWrapper.get File.join($host, "compound/descriptor", bsonid), {}, {:accept => "application/json"}
    json = JSON.parse(result)
    assert_equal json["name"], "Openbabel.HBA1"
    assert_equal json["calculated"], true
  end

  def test_04_post_descriptor
    result = RestClientWrapper.post File.join($host, "compound/descriptor"), {:identifier => "CC(=O)CC(C)C#N", :descriptor => "Joelib.LogP"}, {:accept => "application/csv"}
    assert_equal result.code, 200
    assert_equal "SMILES,\"CC(=O)CC(C)C#N\"\n\"Joelib.LogP\",2.65908", result
  end

  # currently not applicable
  #def test_05_post_descriptor_file
  #  file = File.join(DATA_DIR, "hamster_carcinogenicity.mini.csv")
  #  result = RestClientWrapper.post File.join($host, "compound/descriptor"), {:file => File.open(file), :descriptor => "Openbabel.logP,Cdk.AtomCount,Cdk.CarbonTypes,Joelib.LogP"}, {:accept => "application/json"}
  #  assert_equal result.code, 200
  #  proof_result = File.read(File.join(REST_DATA_DIR, "test_03_post_descriptor_file.result"))
  #  assert_equal result, proof_result.strip
  #end

end
