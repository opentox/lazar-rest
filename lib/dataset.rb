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
      #models[idx][:crossvalidation_uri] = uri("/crossvalidation/#{models[idx]["crossvalidation_id"]["$oid"]}") if models[idx]["crossvalidation_id"]
    end
    return models.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end

end


# d = OpenTox::Dataset.find :id => "57c446d13c58a77ec9baaecf"
# d.data_entries
# d.name d.source
# OpenTox::Substance.find :id => "57c446d23c58a77ec9baaed8"
# OpenTox::Feature.find :id => "57c446d53c58a77ec9bab236"