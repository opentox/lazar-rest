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
  models = OpenTox::Model::Prediction.all
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
  model = OpenTox::Model::Lazar.find params[:id]
  resource_not_found_error "Model with id: #{params[:id]} not found." unless model
  model[:URI] = uri("/model/#{model.id}")
  model[:neighbor_algorithm_parameters][:feature_dataset_uri] = uri("/dataset/#{model[:neighbor_algorithm_parameters][:feature_dataset_id]}") if model[:neighbor_algorithm_parameters][:feature_dataset_id]
  model[:training_dataset_uri] = uri("/dataset/#{model.training_dataset_id}") if model.training_dataset_id
  model[:prediction_feature_uri] = uri("/dataset/#{model.prediction_feature_id}") if model.prediction_feature_id
  return model.to_json
end



post "/model/:id/?" do
  identifier = params[:identifier]
  begin
    # get compound from SMILES
    compound = Compound.from_smiles identifier
  rescue
    @error_report = "Attention, '#{params[:identifier]}' is not a valid SMILES string."
    return @error_report
  end
  model = OpenTox::Model::Lazar.find params[:id]
  prediction = model.predict(compound)
  return prediction.to_json
end

# Get a list of a single or all descriptors
# @param [Header] Accept one of text/plain, application/json
# @param [Path] Descriptor name (e.G.: Openbabel.HBA1)
# @return [text/plain, application/json] list of all prediction models
get "/algorithm/descriptor/?:descriptor?" do
  case @accept
  when "application/json"
    return "#{JSON.pretty_generate OpenTox::Algorithm::Descriptor::DESCRIPTORS} "  unless params[:descriptor]
    return {params[:descriptor] => OpenTox::Algorithm::Descriptor.description(params[:descriptor])}.to_json
  else
    return OpenTox::Algorithm::Descriptor::DESCRIPTORS.collect{|k, v| "#{k}: #{v}\n"} unless params[:descriptor]
    return OpenTox::Algorithm::Descriptor.description  params[:descriptor]
  end
end

get %r{/compound/(.+)} do |inchi|
  inchi = "InChI=#{inchi}" unless inchi.match(/^InChI/)
  compound = OpenTox::Compound.from_inchi inchi
  response['Content-Type'] = @accept
  case @accept
  when "application/json"
    return compound.to_json
  when "chemical/x-daylight-smiles"
    return compound.smiles
  when "chemical/x-inchi"
    return compound.inchi
  when "chemical/x-mdl-sdfile"
    return compound.sdf
  when "chemical/x-mdl-molfile"
  when "image/png"
    return compound.png
  when "image/svg+xml"
    return compound.svg
  when "text/plain"
    return "#{compound.names}\n"
  else
    return compound.inspect
  end
end

