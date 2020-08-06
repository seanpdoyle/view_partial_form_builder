module ViewPartialFormBuilder
  class LookupOverride
    def initialize(prefixes:, object_name:, view_partial_directory:)
      @object_name = object_name.to_s.tableize
      @prefixes = prefixes
      @view_partial_directory = view_partial_directory
    end

    def prefixes
      *overridden_prefixes, root_prefix = @prefixes.dup

      prefixes = [
        "#{object_name}/#{view_partial_directory}",
        "#{root_prefix}/#{view_partial_directory}",
      ]

      overridden_prefixes.reverse_each do |prefix|
        prefixes.unshift("#{prefix}/#{view_partial_directory}")
      end

      prefixes.uniq
    end

    private

    attr_reader :object_name, :view_partial_directory
  end
end
