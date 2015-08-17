$:.unshift(__dir__)

require 'helper'

describe "Page" do
  before { @site = test_site }
  subject { Dimples::Page.new(@site, File.join(@site.source_paths[:pages], 'about.markdown')) }

  it "parses its YAML frontmatter" do
    assert_equal 'About', subject.title
    assert_equal 'default', subject.layout
  end

  it "renders its contents" do
    expected_output = "<h2>About this site</h2>

<p>Hello! I&#39;m an about page.</p>"

    assert_equal expected_output, subject.render
  end

end