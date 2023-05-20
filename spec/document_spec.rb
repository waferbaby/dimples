require "dimples"

describe Dimples::Document do
  context "for a file-based document" do
    subject { Dimples::Document.new("spec/fixtures/document.markdown") }

    it "reads in its frontmatter" do
      expect(subject.metadata).to eql({title: "Test Document", filename: "test", extension: "txt"})
    end

    it "returns the correct filename" do
      expect(subject.filename).to eql("test.txt")
    end
  end

  context "for a dynamically created document" do
    subject { Dimples::Document.new }

    it "returns the correct default filename" do
      expect(subject.filename).to eql("index.html")
    end
  end
end
