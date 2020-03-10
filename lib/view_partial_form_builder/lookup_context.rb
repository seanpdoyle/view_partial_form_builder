module ViewPartialFormBuilder
  class LookupContext
    delegate_missing_to :overridden_context

    def initialize(overridden_context:, object_name:, view_partial_directory:)
      @object_name = object_name.to_s.pluralize
      @overridden_context = overridden_context
      @prefixes = overridden_context.prefixes.dup.freeze
      @view_partial_directory = view_partial_directory
    end

    def override(&block)
      previous_prefixes = overridden_context.prefixes

      overridden_context.prefixes = prefix_overrides

      yield
    ensure
      overridden_context.prefixes = previous_prefixes
    end

    private

    attr_reader :overridden_context, :object_name, :view_partial_directory

    def prefix_overrides
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
  end
end
