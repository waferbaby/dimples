$:.unshift(__dir__)

require 'helper'

describe "Post" do
  before { @site = test_site }
  subject { Dimples::Post.new(@site, File.join(@site.source_paths[:posts], '2015-01-01-a-post.markdown')) }

  it "parses its YAML frontmatter" do
    assert_equal 'My first post', subject.title
    assert_equal %w[a b c], subject.categories.keys.sort
  end

  it "renders its contents" do
    expected_output = "<h3>Hello</h3>

<p>Welcome to my first post. This is <em>awesome</em>.</p>"

    assert_equal expected_output, subject.render
  end

  it "publishes to a file" do
    path = @site.output_paths[:posts]

    subject.write(path)
    assert_equal true, File.exist?(subject.output_file_path(path))
  end
end