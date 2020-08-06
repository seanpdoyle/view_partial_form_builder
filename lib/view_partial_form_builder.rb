require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module ViewPartialFormBuilder
  mattr_accessor :view_partial_directory, default: "form_builder"
end

loader.eager_load
