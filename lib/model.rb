
# Get a list of all prediction models
# @param [Header] Accept one of text/uri-list,
# @return [text/uri-list] list of all prediction models
get "/model/?" do
  models = Model::Validation.all
  case @accept
  when "text/uri-list"
    uri_list = models.collect{|model| uri("/model/#{model.model_id}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    models = JSON.parse models.to_json
    models.each_index do |idx|
      models[idx][:URI] = uri("/model/#{models[idx]["model_id"]["$oid"]}")
      models[idx][:crossvalidation_uri] = uri("/crossvalidation/#{models[idx]["crossvalidation_id"]["$oid"]}") if models[idx]["crossvalidation_id"]
    end
    return models.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end

get "/model/:id/?" do
  model = Model::Lazar.find params[:id]
  resource_not_found_error "Model with id: #{params[:id]} not found." unless model
  model[:URI] = uri("/model/#{model.id}")
  # model[:neighbor_algorithm_parameters][:feature_dataset_uri] = uri("/dataset/#{model[:neighbor_algorithm_parameters][:feature_dataset_id]}") if model[:neighbor_algorithm_parameters][:feature_dataset_id]
  model[:training_dataset_uri] = uri("/dataset/#{model.training_dataset_id}") if model.training_dataset_id
  model[:prediction_feature_uri] = uri("/dataset/#{model.prediction_feature_id}") if model.prediction_feature_id
  return model.to_json
end


post "/model/:id/?" do
  identifier = params[:identifier].split(",")
  begin
    # get compound from SMILES
    compounds = identifier.collect{ |i| Compound.from_smiles i.strip }
  rescue
    @error_report = "Attention, '#{params[:identifier]}' is not a valid SMILES string."
    return @error_report
  end
  model = Model::Lazar.find params[:id]
  batch = {}
  compounds.each do |compound|
    prediction = model.predict(compound)
    batch[compound] = {:id => compound.id, :inchi => compound.inchi, :smiles => compound.smiles, :model => model, :prediction => prediction}
  end
  return batch.to_json
end
