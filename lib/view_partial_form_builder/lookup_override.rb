module ViewPartialFormBuilder
  class LookupOverride
    def initialize(prefixes:, object_name:, view_partial_directory:)
      @object_name = object_name.to_s.pluralize
      @prefixes = prefixes
      @view_partial_directory = view_partial_directory
    end

    def prefixes
      *overridden_prefixes, root_prefix = @prefixes.dup

      prefixes = [
        "#{object_name}/#{view_partial_directory}",
        object_name,
        view_partial_directory,
        "#{root_prefix}/#{view_partial_directory}",
        root_prefix,
      ]

      overridden_prefixes.reverse_each do |prefix|
        namespace, *files = prefix.split("/")

        prefixes.unshift(prefix)

        if namespace.present?
          prefixes.unshift("#{namespace}/#{view_partial_directory}")
        end

        prefixes.unshift("#{prefix}/#{view_partial_directory}")
      end


      prefixes.uniq
    end

    private

    attr_reader :object_name, :view_partial_directory
  end
end
