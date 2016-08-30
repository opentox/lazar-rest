SERVICE = "lazar-rest"
require 'bundler'
Bundler.require
require File.expand_path './lib/lazar-rest.rb'
run Sinatra::Application