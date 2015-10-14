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

# Get a list of all descriptors
# @param [Header] Accept one of text/plain, application/json
# @return [text/plain, application/json] list of all prediction models
get "/algorithm/descriptor/?" do
  case @accept
  when "text/plain"
    return OpenTox::Algorithm::Descriptor::DESCRIPTORS.collect{|k, v| "#{k}: #{v}\n"}
  when "application/json"
    return JSON.pretty_generate OpenTox::Algorithm::Descriptor::DESCRIPTORS
  end
end

=begin
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
=end
