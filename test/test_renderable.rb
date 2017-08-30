# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Renderable do
  before do
    test_site.scan_templates
  end

  describe 'when rendering' do
    describe 'using a source with a file path' do
      subject do
        base_path = test_site.source_paths[:pages]
        file_path = File.join(base_path, 'about', 'contact.markdown')

        Dimples::Page.new(test_site, file_path)
      end

      it 'maps to the correct Tilt engine for the given source file' do
        subject.rendering_engine.class.must_equal(Tilt[subject.path])
      end

      it 'renders the expected output' do
        expected_output = read_fixture('pages/general/about/contact')
        subject.render.must_equal(expected_output)
      end

      describe 'with custom rendering options set' do
        before do
          test_site.config['rendering']['markdown'] = {
            escape_html: true
          }
        end

        it 'passes them on to the Tilt engine' do
          expected_output = read_fixture('pages/general/about/contact_encoded')
          subject.render.must_equal(expected_output)
        end
      end
    end

    describe 'using a source without a file path' do
      subject do
        Dimples::Page.new(test_site).tap do |page|
          page.contents = 'Welcome!'
        end
      end

      it 'maps to the Tilt string template engine' do
        subject.rendering_engine.class.must_equal(Tilt::StringTemplate)
      end

      describe 'and no layout' do
        it 'renders the contents as is' do
          subject.render.must_equal('Welcome!')
        end
      end

      describe 'with a layout' do
        before { subject.layout = 'default' }

        it 'renders the contents with the template' do
          expected_output = read_fixture('pages/general/welcome')
          subject.render.must_equal(expected_output)
        end
      end
    end
  end
end
