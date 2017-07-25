# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Renderer' do
  let(:source) do
    path =
      File.join(test_site.source_paths[:pages], 'escaped', 'index.markdown')
    Dimples::Page.new(test_site, path)
  end

  it 'allows raw html in markdown by default' do
    expected_output = '<p><a href="/this_is_a_test">Test</a></p>'
    renderer = Dimples::Renderer.new(test_site, source)
    renderer.render.must_equal(expected_output)
  end

  describe 'when setting escape_html to true in the rendering options' do
    before do
      test_site.config['rendering']['markdown'] = {
        escape_html: true
      }
    end

    it 'passes it on to the Tilt engine' do
      expected_output =
        '<p>&lt;a href=&quot;/this_is_a_test&quot;&gt;Test&lt;/a&gt;</p>'
      renderer = Dimples::Renderer.new(test_site, source)
      renderer.render.must_equal(expected_output)
    end
  end
end
