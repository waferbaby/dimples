$:.unshift(__dir__)

require 'helper'

describe "Site" do
  subject { @site = test_site }

  describe "building a complete site" do
    before { subject.generate }

    it "prepares the output directory" do
      Dir.exist?(subject.output_paths[:site]).must_equal(true)
    end

    it "prepares the categories" do
      subject.categories["a"].name.must_equal("A")
    end

    describe "scanning for files" do

      it "finds all the templates" do
        subject.templates.length.must_equal(4)
      end

      it "finds all the pages" do
        subject.pages.length.must_equal(1)
      end

      it "finds all the posts" do
        subject.posts.length.must_equal(2)
      end
    end

    describe "generating files" do
      it "generates categories" do
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

          File.exist?(category_file_path).must_equal(true)
          File.read(category_file_path).must_equal(expected_output.strip)
        end
      end
    end
  end
end