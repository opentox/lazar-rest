require 'minitest/autorun'

require_relative '../../lazar/lib/lazar.rb'
require_relative '../../lazar/test/setup.rb'
$host = "https://enm.in-silico.ch"
include OpenTox
REST_TEST_DIR ||= File.expand_path(File.dirname(__FILE__))
REST_DATA_DIR ||= File.join(REST_TEST_DIR,"data")
