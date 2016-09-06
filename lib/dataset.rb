# Get all datasets
get "/dataset/?" do
  datasets = Dataset.all
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

# Get a dataset
get "/dataset/:id/?" do
  dataset = Dataset.find :id => params[:id]
  resource_not_found_error "Dataset with id: #{params[:id]} not found." unless dataset
  dataset.data_entries.each do |k, v|
    dataset.data_entries[k][:URI] = uri("/substance/#{k}")
  end

  dataset[:URI] = uri("/dataset/#{dataset.id}")
  dataset[:substances] = uri("/dataset/#{dataset.id}/substances")
  dataset[:features] = uri("/dataset/#{dataset.id}/features")
  return dataset.to_json
end

# Get a dataset attribute. One of compounds, nanoparticles, substances, features 
get "/dataset/:id/:attribute/?" do
  dataset = Dataset.find :id => params[:id]
  resource_not_found_error "Dataset with id: #{params[:id]} not found." unless dataset
  attribs = ["compounds", "nanoparticles", "substances", "features"]
  return "Attribute '#{params[:attribute]}' is not available. Choose one of #{attribs.join(', ')}." unless attribs.include? params[:attribute]
  out = dataset.send(params[:attribute])
  return out.to_json
end
