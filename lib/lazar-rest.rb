require "sinatra"
require "sinatra/reloader"
require 'sinatra/cross_origin'

configure do
  enable :reloader if development?
  enable :cross_origin
end

#set :protection, :except => :frame_options

# Environment setup from unicorn -E param
ENV["LAZAR_ENV"] = ENV["RACK_ENV"]

if ENV["LAZAR_ENV"] == "development"
  require "../lazar/lib/lazar.rb"
  require "../qsar-report/lib/qsar-report.rb"
else
  require "lazar"
  require "qsar-report"
end

include OpenTox
#require 'rack/cors'


set :show_exceptions => false
=begin
# add CORS support for swagger
  config.allow do |allow|
    allow.origins '*'
    allow.resource "/#{SERVICE}/*",
      :methods => [:head, :get, :post, :put, :delete, :options],
      :headers => :any,
      :max_age => 0
  end
end
=end
before do
  @accept = request.env['HTTP_ACCEPT'].split.last
  response['Content-Type'] = @accept
end

# https://github.com/britg/sinatra-cross_origin#responding-to-options
options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,POST,DELETE,OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  200
end



[
  "aa.rb",
  "api.rb",
  "compound.rb",
  "dataset.rb",
  "feature.rb",
  "model.rb",
  "nanoparticle.rb",
  "report.rb",
  "substance.rb",
  "swagger.rb",
  "validation.rb"
].each{ |f| require_relative f }
