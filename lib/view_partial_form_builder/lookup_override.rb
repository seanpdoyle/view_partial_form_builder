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

    def prefixes_after(current_prefix)
      if prefixes.include?(current_prefix)
        prefixes.from(prefixes.index(current_prefix).to_i + 1)
      else
        prefixes
      end
    end

    private

    attr_reader :object_name, :view_partial_directory
  end
end
