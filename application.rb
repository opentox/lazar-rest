include OpenTox

require 'rack/cors'
#require_relative "helper.rb"

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
 
# route to swagger API file
get "/api/api.json" do
  response['Content-Type'] = "application/json"
  api_file = File.join("api", "api.json")
  bad_request_error "API Documentation in Swagger JSON is not implemented.", uri("/#{SERVICE}/api") unless File.exists?(api_file)
  File.read(api_file)
end


# Get a list of all prediction models
# @param [Header] Accept one of text/uri-list,
# @return [text/uri-list] list of all prediction models
get "/model/?" do
  @models = OpenTox::Model::Prediction.all
  uri_list = @models.collect{|model| uri("/model/#{model.model_id}")}
  case @accept
  when "text/uri-list"
    return uri_list.join("\n") + "\n"
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end

get "/model/:id/?" do
  @model = OpenTox::Model::Lazar.find params[:id]
  return @model.to_json
end

post "/model/?" do
  parse_input
  case @content_type
  when "text/csv", "text/comma-separated-values"
    model = OpenTox::Model::Prediction.from_csv_file @body
  else
    bad_request_error "Mime type #{@content_type} is not supported."
  end
  response['Content-Type'] = "text/uri-list"
  model.model_id
end

delete "model/:id/?" do
  model = OpenTox::Model::Lazar.find params[:id]
  model.delete
end
