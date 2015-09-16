require 'minitest/autorun'

require_relative '../../lazar/lib/lazar.rb'
include OpenTox
TEST_DIR ||= File.expand_path(File.dirname(__FILE__))
DATA_DIR ||= File.join(TEST_DIR,"data")
