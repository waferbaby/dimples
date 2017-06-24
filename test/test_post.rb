# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Post' do
  subject do
    path = File.join(test_site.source_paths[:posts], '2015-01-01-a-post.markdown')
    Dimples::Post.new(test_site, path)
  end

  it 'parses its YAML frontmatter' do
    subject.title.must_equal('My first post')
    subject.categories.sort.must_equal(%w[a b c])
  end

  it 'renders its contents' do
    expected_output = render_fixture('post.erb')
    subject.render.must_equal(expected_output)
  end

  it 'publishes to a file' do
    path = subject.output_path(test_site.output_paths[:posts])

    subject.write(path)
    File.exist?(path).must_equal(true)
  end
end
