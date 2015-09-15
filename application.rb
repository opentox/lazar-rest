include OpenTox

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
 
# route to swagger API file
get "/api/api.json" do
  response['Content-Type'] = "application/json"
  api_file = File.join("api", "api.json")
  bad_request_error "API Documentation in Swagger JSON is not implemented.", uri("/#{SERVICE}/api") unless File.exists?(api_file)
  File.read(api_file)
end
