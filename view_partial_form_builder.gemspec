$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "view_partial_form_builder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "view_partial_form_builder"
  spec.version     = ViewPartialFormBuilder::VERSION
  spec.authors     = ["Sean Doyle"]
  spec.email       = ["sean.p.doyle24@gmail.com"]
  spec.homepage    = "https://github.com/seanpdoyle/view_partial_form_builder"
  spec.summary     = "Construct <form> element fields by combining ActionView::Helpers::FormBuilder with Rails View Partials"
  spec.description = "A Rails form builder where all designer-facing configuration is via templates."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "actionview", ">= 4.0.0"
  spec.add_dependency "railties", ">= 4.0.0"
  spec.add_dependency "zeitwerk", ">= 2.4.0"

  spec.add_development_dependency "minitest-around"
  spec.add_development_dependency "activemodel", ">= 4.0.0"
  spec.add_development_dependency "activerecord-nulldb-adapter"
end
