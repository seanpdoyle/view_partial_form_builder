require "test_helper"

module TemplateDeclarationHelpers
  def around(&block)
    @partial_path = Pathname(Dir.mktmpdir).join("app", "views")

    with_view_path_prefixes(@partial_path) do
      block.call
    end
  end

  def with_view_path_prefixes(temporary_view_directory, &block)
    view_paths = ActionController::Base.view_paths

    ActionController::Base.prepend_view_path(temporary_view_directory)

    block.call
  ensure
    ActionController::Base.view_paths = view_paths
  end

  def declare_template(partial, html)
    @partial_path.join(partial).tap do |file|
      file.dirname.mkpath

      file.write(html)
    end
  end
end
