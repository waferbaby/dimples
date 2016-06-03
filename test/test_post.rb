$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Post' do
  before { @site = test_site }
  subject do
    path = File.join(@site.source_paths[:posts], '2015-01-01-a-post.markdown')
    Dimples::Post.new(@site, path)
  end

  it 'parses its YAML frontmatter' do
    subject.title.must_equal('My first post')
    subject.categories.sort.must_equal(%w(a b c))
  end

  it 'renders its contents' do
    expected_output = render_fixture('post.erb')
    subject.render.must_equal(expected_output)
  end

  it 'publishes to a file' do
    path = @site.output_paths[:posts]

    subject.write(path)
    File.exist?(subject.output_file_path(path)).must_equal(true)
  end
end
