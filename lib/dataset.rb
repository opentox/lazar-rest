include OpenTox

# route to swagger API file
get "/dataset/?" do
  datasets = OpenTox::Dataset.all
  case @accept
  when "text/uri-list"
    uri_list = datasets.collect{|dataset| uri("/dataset/#{dataset.id}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    datasets = JSON.parse datasets.to_json
    datasets.each_index do |idx|
      datasets[idx][:URI] = uri("/dataset/#{datasets[idx]["_id"]["$oid"]}")
    end
    return datasets.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end


get "/dataset/:id/?" do
  dataset = Dataset.find :id => params[:id]
  resource_not_found_error "Dataset with id: #{params[:id]} not found." unless dataset
  dataset[:URI] = uri("/dataset/#{dataset.id}")
  dataset[:substances] = uri("/dataset/#{dataset.id}/substances")
  dataset[:features] = uri("/dataset/#{dataset.id}/features")
  return dataset.to_json
end


get "/dataset/:id/:attribute/?" do
  dataset = Dataset.find :id => params[:id]
  resource_not_found_error "Dataset with id: #{params[:id]} not found." unless dataset
  attribs = ["compounds", "nanoparticles", "substances", "features"]
  bad_request_error "Attribute #{params[:attribute]} is not availabe. Choose one of #{attribs.join(', ')}" unless attribs.include? params[:attribute]
  out = dataset.send(params[:attribute])
  return out.to_json
end


# d = OpenTox::Dataset.find :id => "57c446d13c58a77ec9baaecf"
# d.data_entries
# d.name d.source
# OpenTox::Substance.find :id => "57c446d23c58a77ec9baaed8"
# OpenTox::Feature.find :id => "57c446d53c58a77ec9bab236"