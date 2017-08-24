# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Page' do
  before { test_site.scan_files }

  subject do
    path = File.join(test_site.source_paths[:pages], 'about', 'index.markdown')
    Dimples::Page.new(test_site, path)
  end

  it 'parses its YAML frontmatter' do
    subject.title.must_equal('About')
    subject.layout.must_equal('default')
  end

  it 'renders its contents' do
    expected_output = read_fixture('pages/general/about')
    subject.render.must_equal(expected_output)
  end

  it 'publishes to a file' do
    path = subject.output_path(test_site.output_paths[:site])

    subject.write(path)
    File.exist?(path).must_equal(true)
  end
end
