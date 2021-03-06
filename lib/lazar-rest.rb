require "sinatra"
require "../lazar/lib/lazar.rb"
require "../qsar-report/lib/qsar-report.rb"
include OpenTox

require 'rack/cors'


set :show_exceptions => false

# add CORS support for swagger
use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource "/#{SERVICE}/*",
      :methods => [:head, :get, :post, :put, :delete, :options],
      :headers => :any,
      :max_age => 0
  end
end
before do
  @accept = request.env['HTTP_ACCEPT']
  response['Content-Type'] = @accept
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
  "validation.rb"
].each{ |f| require_relative f }
