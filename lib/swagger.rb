set :public_folder, File.join("/home/ist/swagger-ui/dist/")
# route to swagger API file
get "/" do
  response['Content-Type'] = "text/html"
  index_file = File.join("/home/ist/swagger-ui/dist/index.html")
  bad_request_error "API Documentation in Swagger JSON is not implemented.", uri("/#{SERVICE}/api") unless File.exists?(index_file)
  File.read(index_file)
end
