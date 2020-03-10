module ViewPartialFormBuilder
  class HtmlAttributes
    def initialize(**attributes)
      @attributes = attributes
    end

    def merge_token_lists(**token_list_attributes)
      merge(
        token_list_attributes.reduce({}) do |merged, (key, value)|
          token_list = Array(attributes.delete(key)).unshift(value)

          merged.merge(key => token_list.flatten.uniq)
        end
      )
    end

    def to_h
      attributes.to_h
    end

    def to_hash
      attributes.to_hash
    end

    def method_missing(method_name, *arguments, &block)
      if attributes.respond_to?(method_name)
        return_value = attributes.public_send(method_name, *arguments, &block)

        if return_value.kind_of?(Hash)
          HtmlAttributes.new(return_value)
        else
          return_value
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      attributes.respond_to?(method_name) || super
    end

    private

    attr_reader :attributes
  end
end
