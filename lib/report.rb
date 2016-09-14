# Get a list of all possible reports to prediction models
# @param [Header] Accept one of text/uri-list,
# @return [text/uri-list] list of all prediction models
get "/report/?" do
  models = Model::Prediction.all
  case @accept
  when "text/uri-list"
    uri_list = models.collect{|model| uri("/report/#{model.model_id}")}
    return uri_list.join("\n") + "\n"
  when "application/json"
    reports = [{}]
    #models = JSON.parse models.to_json
    models.each_index do |idx|
      reports[idx] = {}
      reports[idx][:URI] = uri("/report/#{models[idx]["model_id"]}")
      reports[idx][:repeated_crossvalidation_uri] = uri("/validation/repeatedcrossvalidation/#{models[idx]["repeated_crossvalidation_id"]}") if models[idx]["repeated_crossvalidation_id"]
      reports[idx][:leave_one_out_validation_uri] = uri("/validation/leaveoneoutvalidation/#{models[idx]["leave_one_out_validation_id"]}") if models[idx]["leave_one_out_validation_id"]
      reports[idx][:training_dataset_URI] = uri("/dataset/#{models[idx].training_dataset.id}") if models[idx].training_dataset.id 
    end
    return reports.to_json
  else
    bad_request_error "Mime type #{@accept} is not supported."
  end
end

get "/report/:id/?" do
  model = Model::Lazar.find params[:id]
  resource_not_found_error "Model with id: #{params[:id]} not found." unless model
  prediction_model = Model::Prediction.find_by :model_id => params[:id]

  if File.directory?("#{File.dirname(__FILE__)}/../../lazar")
    lazar_commit = `cd #{File.dirname(__FILE__)}/../../lazar; git rev-parse HEAD`.strip
    lazar_commit = "https://github.com/opentox/lazar/tree/#{lazar_commit}"
  else
    lazar_commit = "https://github.com/opentox/lazar/releases/tag/v#{Gem.loaded_specs["lazar"].version}"
  end

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

  # Type of model 4.1
  report.value "algorithm_type", "#{model.class.to_s.gsub('OpenTox::Model::Lazar','')}"

  # Explicit algorithm 4.2
  report.change_catalog :algorithms_catalog, :algorithms_catalog_1, {:definition => "see Helma 2016 and lazar.in-silico.ch, submitted version: #{lazar_commit}", :description => "modified k-nearest neighbor classification with activity specific similarities, weighted voting and exhaustive enumeration of fragments and neighbors"}
  report.ref_catalog :algorithm_explicit, :algorithms_catalog, :algorithms_catalog_1

  # Descriptors in the model 4.3
  report.change_catalog :descriptors_catalog, :descriptors_catalog_1, {:description => "all statistically relevant paths are used for similarity calculation", :name => "linear fragmens (paths)", :publication_ref => "", :units => "true/false (i.e. present/absent)"}
  report.ref_catalog :algorithms_descriptors, :descriptors_catalog, :descriptors_catalog_1

  # Descriptor selection 4.4
  report.value "descriptors_selection", "statistical filter (chi-square with Yates correction)"
  
  # Algorithm and descriptor generation 4.5
  report.value "descriptors_generation", "exhaustive breadth first search for paths in chemical graphs (simplified MolFea algorithm)"
  
  # Software name and version for descriptor generation 4.6
  report.change_catalog :software_catalog, :software_catalog_2, {:name => "lazar, submitted version: #{lazar_commit}", :description => "simplified MolFea algorithm", :number => "2", :url => "https://lazar.in-silico.ch", :contact => "info@in-silico.ch"}
  report.ref_catalog :descriptors_generation_software, :software_catalog, :software_catalog_2

  # Chemicals/Descriptors ratio 4.7
  report.value "descriptors_chemicals_ratio", "not applicable (classification based on activities of neighbors, descriptors are used for similarity calculation)"

  # Description of the applicability domain of the model 5.1
  report.value "app_domain_description", "&lt;html&gt;
    &lt;head&gt;
      
    &lt;/head&gt;
    &lt;body&gt;
      &lt;p&gt;
        The applicability domain (AD) of the training set is characterized by 
        the confidence index of a prediction (high confidence index: close to 
        the applicability domain of the training set/reliable prediction, low 
        confidence: far from the applicability domain of the 
        trainingset/unreliable prediction). The confidence index considers (i) 
        the similarity and number of neighbors and (ii) contradictory examples 
        within the neighbors. A formal definition can be found in Helma 2006.
      &lt;/p&gt;
      &lt;p&gt;
        The reliability of predictions decreases gradually with increasing 
        distance from the applicability domain (i.e. decreasing confidence index)
      &lt;/p&gt;
    &lt;/body&gt;
  &lt;/html&gt;"

  # Method used to assess the applicability domain 5.2
  report.value "app_domain_method", "see Helma 2006 and Maunz 2008"
  
  # Software name and version for applicability domain assessment 5.3  
  report.change_catalog :software_catalog, :software_catalog_3, {:name => "lazar, submitted version: #{lazar_commit}", :description => "integrated into main lazar algorithm", :number => "3", :url => "https://lazar.in-silico.ch", :contact => "info@in-silico.ch"}
  report.ref_catalog :app_domain_software, :software_catalog, :software_catalog_3

  # Limits of applicability 5.4
  report.value "applicability_limits", "Predictions with low confidence index, unknown substructures and neighbors that might act by different mechanisms"

  # Availability of the training set 6.1
  report.change_attributes "training_set_availability", {:answer => "Yes"}

  # Available information for the training set 6.2
  report.change_attributes "training_set_data", {:cas => "Yes", :chemname => "Yes", :formula => "Yes", :inchi => "Yes", :mol => "Yes", :smiles => "Yes"}

  # Data for each descriptor variable for the training set 6.3
  report.change_attributes "training_set_descriptors", {:answer => "No"}

  # Data for the dependent variable for the training set 6.4
  report.change_attributes "dependent_var_availability", {:answer => "All"}

  # Other information about the training set 6.5
  report.value "other_info", "#{model.source}"

  # Pre-processing of data before modelling 6.6
  report.value "preprocessing", (model.class == OpennTox::Model::LazarRegression ? "-Log 10 transformation" : "none")

  # output
  response['Content-Type'] = "application/xml"
  return report.to_xml

end
