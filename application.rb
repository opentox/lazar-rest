include OpenTox

require 'rack/cors'

set :show_exceptions => false

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
  api_hash = JSON.parse(File.read(api_file))
  api_hash["host"] = request.env['HTTP_HOST']
  return api_hash.to_json
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
  identifier = params[:identifier].split(",")
  begin
    # get compound from SMILES
    compounds = identifier.collect{ |i| Compound.from_smiles i.strip }
  rescue
    @error_report = "Attention, '#{params[:identifier]}' is not a valid SMILES string."
    return @error_report
  end
  model = OpenTox::Model::Lazar.find params[:id]
  batch = {}
  compounds.each do |compound|
    prediction = model.predict(compound)
    batch[compound] = {:id => compound.id, :inchi => compound.inchi, :smiles => compound.smiles, :model => model, :prediction => prediction}
  end
  return batch.to_json
end

VALIDATION_TYPES = ["repeatedcrossvalidation", "leaveoneout", "crossvalidation", "regressioncrossvalidation"]


# Get a list of ayll possible validation types
# @param [Header] Accept one of text/uri-list, application/json
# @return [text/uri-list] URI list of all validation types
get "/validation/?" do
  case @accept
  when "text/uri-list"
    uri_list = VALIDATION_TYPES.collect{|validationtype| uri("/validation/#{validationtype}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    return VALIDATION_TYPES.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end


# Get a list of all validations 
# @param [Header] Accept one of text/uri-list, application/json
# @param [Path] Validationtype One of "repeatedcrossvalidation", "leaveoneout", "crossvalidation", "regressioncrossvalidation"
# @return [text/uri-list] list of all validations of a validation type
get "/validation/:validationtype/?" do
  bad_request_error "There is no such validation type as: #{params[:validationtype]}" unless VALIDATION_TYPES.include? params[:validationtype]
  case params[:validationtype]
  when "repeatedcrossvalidation"
    validations = OpenTox::Validation::RepeatedCrossValidation.all
  when "leaveoneout"
    validations = OpenTox::Validation::LeaveOneOut.all
  when "crossvalidation"
    validations = OpenTox::Validation::CrossValidation.all
  when "regressioncrossvalidation"
    validations = OpenTox::Validation::RegressionCrossValidation.all
  end

  case @accept
  when "text/uri-list"
    uri_list = validations.collect{|validation| uri("/validation/#{params[:validationtype]}/#{validation.id}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    validations = JSON.parse validations.to_json
    validations.each_index do |idx|
      validations[idx][:URI] = uri("/validation/#{params[:validationtype]}/#{validations[idx]["$oid"]}")
      #models[idx][:crossvalidation_uri] = uri("/crossvalidation/#{models[idx]["crossvalidation_id"]["$oid"]}") if models[idx]["crossvalidation_id"]
    end
    return validations.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end

get "/validation/:validationtype/:id/?" do
  bad_request_error "There is no such validation type as: #{params[:validationtype]}" unless VALIDATION_TYPES.include? params[:validationtype]
  case params[:validationtype]
  when "repeatedcrossvalidation"
    validation = OpenTox::Validation::RepeatedCrossValidation.find params[:id]
  when "leaveoneout"
    validation = OpenTox::Validation::LeaveOneOut.find params[:id]
  when "crossvalidation"
    validation = OpenTox::Validation::CrossValidation.find params[:id]
  when "regressioncrossvalidation"
    validation = OpenTox::Validation::RegressionCrossValidation.find params[:id]
  end

  resource_not_found_error "#{params[:validationtype]} with id: #{params[:id]} not found." unless validation
  #model[:URI] = uri("/model/#{model.id}")
  #model[:neighbor_algorithm_parameters][:feature_dataset_uri] = uri("/dataset/#{model[:neighbor_algorithm_parameters][:feature_dataset_id]}") if model[:neighbor_algorithm_parameters][:feature_dataset_id]
  #model[:training_dataset_uri] = uri("/dataset/#{model.training_dataset_id}") if model.training_dataset_id
  #model[:prediction_feature_uri] = uri("/dataset/#{model.prediction_feature_id}") if model.prediction_feature_id
  return validation.to_json
end

# Get a list of a single or all descriptors
# @param [Header] Accept one of text/plain, application/json
# @param [Path] Descriptor name (e.G.: Openbabel.HBA1)
# @return [text/plain, application/json] list of all prediction models
get "/compound/descriptor/?:descriptor?" do
  case @accept
  when "application/json"
    return "#{JSON.pretty_generate OpenTox::PhysChem::DESCRIPTORS} "  unless params[:descriptor]
    return {params[:descriptor] => OpenTox::PhysChem::DESCRIPTORS[params[:descriptor]]}.to_json
  else
    return OpenTox::PhysChem::DESCRIPTORS.collect{|k, v| "#{k}: #{v}\n"} unless params[:descriptor]
    return OpenTox::PhysChem::DESCRIPTORS[params[:descriptor]]
  end
end

post "/compound/descriptor/?" do
  bad_request_error "Missing Parameter " unless (params[:identifier] or params[:file]) and params[:descriptor]
  descriptor = params['descriptor'].split(',')
  if params[:file]
    data = OpenTox::Dataset.from_csv_file params[:file][:tempfile]
  else
    data = OpenTox::Compound.from_smiles params[:identifier]
  end
  d = Algorithm::Descriptor.physchem data, descriptor
  csv = d.to_csv
  csv = "SMILES,#{params[:descriptor]}\n#{params[:identifier]},#{csv}" if params[:identifier]
  case @accept
  when "application/csv"
    return csv
  when "application/json"
    lines = CSV.parse(csv)
    keys = lines.delete lines.first
    data = lines.collect{|values|Hash[keys.zip(values)]}
    return JSON.pretty_generate(data)
  end
end

get %r{/compound/(.+)} do |inchi|
  bad_request_error "Input parameter #{inchi} is not an InChI" unless inchi.match(/^InChI=/)
  compound = OpenTox::Compound.from_inchi URI.unescape(inchi)
  response['Content-Type'] = @accept
  case @accept
  when "application/json"
    return JSON.pretty_generate JSON.parse(compound.to_json)
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

