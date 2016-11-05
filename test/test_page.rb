$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Page' do
  before { @site = test_site }
  subject do
    path = File.join(@site.source_paths[:pages], 'about', 'index.markdown')
    Dimples::Page.new(@site, path)
  end

  it 'parses its YAML frontmatter' do
    subject.title.must_equal('About')
    subject.layout.must_equal('default')
  end

  it 'renders its contents' do
    expected_output = render_fixture('page.erb')
    subject.render.must_equal(expected_output)
  end

  it 'publishes to a file' do
    path = subject.output_path(@site.output_paths[:site])

    subject.write(path)
    File.exist?(path).must_equal(true)
  end
end
