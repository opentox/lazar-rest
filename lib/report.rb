# Get a list of all possible reports to prediction models
# @param [Header] Accept one of text/uri-list,
# @return [text/uri-list] list of all prediction models
get "/model/report/?" do
  models = Model::Prediction.all
  case @accept
  when "text/uri-list"
    uri_list = models.collect{|model| uri("/model/report/#{model.model_id}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    reports = [{}]
    #models = JSON.parse models.to_json
    models.each_index do |idx|
      reports[idx] = {}
      reports[idx][:URI] = uri("/model/report/#{models[idx]["model_id"]}")
      reports[idx][:repeated_crossvalidation_uri] = uri("/validation/repeatedcrossvalidation/#{models[idx]["repeated_crossvalidation_id"]}") if models[idx]["repeated_crossvalidation_id"]
      reports[idx][:leave_one_out_validation_uri] = uri("/validation/leaveoneoutvalidation/#{models[idx]["leave_one_out_validation_id"]}") if models[idx]["leave_one_out_validation_id"]
      reports[idx][:training_dataset_URI] = uri("/dataset/#{models[idx].training_dataset.id}") if models[idx].training_dataset.id 
    end
    return reports.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end

get "/model/report/:id/?" do
  model = Model::Lazar.find params[:id]
  resource_not_found_error "Model with id: #{params[:id]} not found." unless model
  prediction_model = Model::Prediction.find_by :model_id => params[:id]

  report = OpenTox::QMRFReport.new
  
  # QSAR Identifier Title 1.1
  report.value "QSAR_title", "Lazar model for #{prediction_model.species} #{prediction_model.endpoint}"

  # Software coding the model 1.3
  report.change_catalog :software_catalog, :firstsoftware, {:name => "lazar", :description => "lazar Lazy Structure- Activity Relationships", :number => "1", :url => "https://lazar.in-silico.ch", :contact => "info@in-silico.ch"}
  report.ref_catalog :QSAR_software, :software_catalog, :firstsoftware
  
  # Date of QMRF 2.1
  report.value "qmrf_date", "#{Time.now.strftime('%d %B %Y')}"
  
  # QMRF author(s) and contact details 2.1
  report.change_catalog :authors_catalog, :firstauthor, {:name => "Christoph Helma", :affiliation => "in silico toxicology gmbh", :contact => "Rastatterstr. 41, CH-4057 Basel", :email => "info@in-silico.ch", :number => "1", :url => "www.in-silico.ch"}
  report.ref_catalog :qmrf_authors, :authors_catalog, :firstauthor
  
  # Model developer(s) and contact details 2.5
  report.change_catalog :authors_catalog, :modelauthor, {:name => "Christoph Helma", :affiliation => "in silico toxicology gmbh", :contact => "Rastatterstr. 41, CH-4057 Basel", :email => "info@in-silico.ch", :number => "1", :url => "www.in-silico.ch"}
  report.ref_catalog :model_authors, :authors_catalog, :modelauthor
  
  # Date of model development and/or publication 2.6
  report.value "model_date", "#{Time.parse(model.created_at.to_s).strftime('%Y')}"
  
  # Reference(s) to main scientific papers and/or software package 2.7
  report.change_catalog :publications_catalog, :publications_catalog_1, {:title => "lazar: a modular predictive toxicology framework", :url => "http://dx.doi.org/10.3389/fphar.2013.00038"}
  report.ref_catalog :references, :publications_catalog, :publications_catalog_1
  
  # Species 3.1
  report.value "model_species", prediction_model.species 
  
  # Endpoint 3.2 
  report.change_catalog :endpoints_catalog, :endpoints_catalog_1, {:name => prediction_model.endpoint, :group => ""}
  report.ref_catalog :model_endpoint, :endpoints_catalog, :endpoints_catalog_1
  
  # Endpoint Units 3.4
  report.value "endpoint_units", "#{prediction_model.unit}"
  response['Content-Type'] = "application/xml"
  return report.to_xml

end
