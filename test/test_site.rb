$:.unshift(__dir__)

require 'helper'

describe "Site" do
  subject { @site = test_site }

  it "creates the output directory" do
    subject.prepare_site
    assert_equal true, Dir.exist?(subject.output_paths[:site])
  end

  describe "scanning files" do
    before { subject.scan_files }

    it "finds all the templates" do
      assert_equal 4, subject.templates.length
    end

    it "finds all the pages" do
      assert_equal 1, subject.pages.length
    end

    it "finds all the posts" do
      assert_equal 2, subject.posts.length
    end
  end

  it "generates categories" do
    subject.scan_files
    subject.generate_categories

    subject.categories.keys.each do |slug|
      expected_output = <<OUTPUT
<!DOCTYPE html>
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>My site</title>
</head>
<body>
<h2>#{slug.upcase} Posts</h2>

<ul>
  <li><a href="/archives/2015/01/01/another-post/">My second post</a></li>
  <li><a href="/archives/2015/01/01/a-post/">My first post</a></li>
</ul>
</body>
</html>
OUTPUT

      category_file_path = File.join(subject.output_paths[:posts], slug, "index.html")

      assert_equal true, File.exist?(category_file_path)
      assert_equal expected_output.strip, File.read(category_file_path)
    end
  end
end