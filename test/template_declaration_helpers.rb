require "test_helper"
require "fileutils"

module TemplateDeclarationHelpers
  extend ActiveSupport::Concern

  def declare_template(partial, html)
    Dummy::Application.root.join("app", "views", partial).tap do |file|
      @partials.push(file)

      FileUtils.mkdir_p(file.dirname)

      file.write(html)
    end
  end

  included do
    setup do
      ActionView::LookupContext::DetailsKey.clear
      @partials = []
    end

    teardown do
      @partials.select(&:exist?).each do |partial|
        partial.unlink

        if partial.dirname.empty?
          partial.dirname.unlink
        end
      end
    end
  end
end
