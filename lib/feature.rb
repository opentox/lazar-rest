# Get all Features
get "/feature/?" do
  features = Feature.all
  case @accept
  when "text/uri-list"
    uri_list = features.collect{|feature| uri("/feature/#{feature.id}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    features = JSON.parse features.to_json
    features.each_index do |idx|
      features[idx][:URI] = uri("/feature/#{features[idx]["_id"]["$oid"]}")
    end
    return features.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end

# Get a feature
get "/feature/:id/?" do
  feature = Feature.find :id => params[:id]
  resource_not_found_error "Feature with id: #{params[:id]} not found." unless feature
  feature[:URI] = uri("/feature/#{feature.id}")
  return feature.to_json
end