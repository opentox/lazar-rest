require_relative "setup.rb"

class AATest < MiniTest::Test

  def self.test_order
    :alpha
  end

  def test_0_login
    res = RestClientWrapper.post(File.join($host,"aa/authenticate"),{:username=>"guest", :password => "guest"},{:Accept => "text/plain"})
    assert_equal res.code, 200
    assert_equal res.size, 62
    @@token = res
  end
  
  def test_1_logout
    assert @@token
    assert_equal @@token.size, 62
    res = RestClientWrapper.post(File.join($host,"aa/logout"),{:subjectid=>@@token},{:Accept => "text/plain"})
    assert_equal res.code, 200
    assert_equal res, "Successfully logged out. \n"
    res = RestClientWrapper.post(File.join($host,"aa/logout"),{:subjectid=>@@token},{:Accept => "text/plain"})
    assert_equal res.code, 200
    assert_equal res, "Logout failed.\n"
  end  

end
