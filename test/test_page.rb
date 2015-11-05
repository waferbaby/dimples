$:.unshift(__dir__)

require 'helper'

describe "Page" do
  before { @site = test_site }
  subject { Dimples::Page.new(@site, File.join(@site.source_paths[:pages], 'about', 'index.markdown')) }

  it "parses its YAML frontmatter" do
    subject.title.must_equal('About')
    subject.layout.must_equal('default')
  end

  it "renders its contents" do
    expected_output = <<OUTPUT
<h2>About this site</h2>

<p>Hello! I&#39;m an about page.</p>
OUTPUT

    subject.render.must_equal(expected_output.strip)
  end

  it "publishes to a file" do
    path = @site.output_paths[:site]

    subject.write(path)
    File.exist?(subject.output_file_path(path)).must_equal(true)
  end
end