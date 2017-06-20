# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "lazar-rest"
  s.version     = File.read("./VERSION")
  s.authors     = ["Christoph Helma","Micha Rautenberg","Denis Gebele"]
  s.email       = ["support@in-silico.ch"]
  s.homepage    = "http://github.com/opentox/lazar-rest"
  s.summary     = %q{lazar-rest}
  s.description = %q{REST Interface for Lazar Toxicology Predictions}
  s.license     = 'GPL-3'

  s.rubyforge_project = "lazar-rest"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.required_ruby_version = '>= 2.0.0'

  s.add_runtime_dependency "lazar"
  s.add_runtime_dependency "qsar-report"
  s.add_runtime_dependency "sinatra"
  s.add_runtime_dependency "haml"
  s.add_runtime_dependency "sass"
  s.add_runtime_dependency "unicorn"
  s.add_runtime_dependency 'rack-cors'
end
