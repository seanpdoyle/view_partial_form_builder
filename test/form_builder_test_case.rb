require "test_helper"
require "template_declaration_helpers"

class FormBuilderTestCase < ActiveSupport::TestCase
  include Rails::Dom::Testing::Assertions
  include TemplateDeclarationHelpers

  def render(*arguments, renderer: ApplicationController.renderer, **options, &block)
    renderer.render(*arguments, **options, &block).tap do |rendered|
      @document_root_element = Nokogiri::HTML(rendered)
    end
  end

  def document_root_element
    if @document_root_element.nil?
      raise "Don't forget to call `render`"
    end

    @document_root_element
  end

  def declare_translations(locale = :en, **translations)
    I18n.backend = I18n::Backend::Simple.new

    I18n.backend.store_translations(locale, translations)
  end

  def around(&block)
    @document_root_element = nil
    i18n_backend = I18n.backend

    super(&block)
  ensure
    I18n.backend = i18n_backend
  end
end
