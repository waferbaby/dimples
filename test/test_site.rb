$:.unshift(__dir__)

require 'helper'

describe "Site" do
  subject { @site = test_site }

  it "creates the output directory" do
    subject.prepare_site
    assert_equal true, Dir.exist?(subject.output_paths[:site])
  end

  describe "scanning files" do
    before do
      subject.scan_files
    end

    it "finds all the templates" do
      assert_equal 3, subject.templates.length
    end

    it "finds all the pages" do
      assert_equal 1, subject.pages.length
    end

    it "finds all the posts" do
      assert_equal 2, subject.posts.length
    end
  end
end