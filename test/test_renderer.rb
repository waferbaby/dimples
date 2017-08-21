# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Renderer' do
  before do
    test_site.scan_templates
  end

  subject do
    path = File.join(test_site.source_paths[:pages], 'about', 'contact.markdown')
    Dimples::Page.new(test_site, path)
  end

  let(:renderer) do
    Dimples::Renderer.new(test_site, subject)
  end

  describe 'when rendering' do
    it 'allows raw HTML in Markdown by default' do
      expected_output = read_fixture('pages/contact_with_html')
      renderer.render.must_equal(expected_output)
    end

    describe 'with custom rendering options set' do
      before do
        test_site.config['rendering']['markdown'] = {
          escape_html: true
        }
      end

      it 'passes them on to the Tilt engine' do
        expected_output = read_fixture('pages/contact_with_html_encoded')
        renderer.render.must_equal(expected_output)
      end
    end
  end
end
