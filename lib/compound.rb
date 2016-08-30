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