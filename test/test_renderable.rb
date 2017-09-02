# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Renderable do
  before do
    @site = Dimples::Site.new(test_configuration)
    @site.scan_files
  end

  describe 'when rendering' do
    describe 'using a source with a file path' do
      before do
        @page = Dimples::Page.new(
          @site,
          File.join(@site.source_paths[:pages], 'about', 'contact.markdown')
        )
      end

      it 'maps to the correct Tilt engine for the given source file' do
        @page.rendering_engine.class.must_equal(Tilt[@page.path])
      end

      it 'renders the expected output' do
        expected_output = fixtures['pages.about.contact']
        @page.render.must_equal(expected_output)
      end

      describe 'with custom rendering options set' do
        before do
          @site.config['rendering']['markdown'] = {
            escape_html: true
          }
        end

        it 'passes them on to the Tilt engine' do
          expected_output = fixtures['pages.about.contact_encoded']
          @page.render.must_equal(expected_output)
        end
      end
    end

    describe 'using a source without a file path' do
      before do
        @page = Dimples::Page.new(@site).tap do |page|
          page.contents = 'Welcome!'
        end
      end

      it 'maps to the Tilt string template engine' do
        @page.rendering_engine.class.must_equal(Tilt::StringTemplate)
      end

      describe 'and no layout' do
        it 'renders the contents as is' do
          @page.render.must_equal('Welcome!')
        end
      end

      describe 'with a layout' do
        before { @page.layout = 'default' }

        it 'renders the contents with the template' do
          expected_output = fixtures['pages.welcome']
          @page.render.must_equal(expected_output)
        end
      end
    end
  end
end
