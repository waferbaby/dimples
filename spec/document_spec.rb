require "dimples"

describe Dimples::Document do
  context "when a file-based document" do
    subject(:document) { described_class.new("spec/fixtures/document.markdown") }

    it "reads in its frontmatter" do
      expect(document.metadata).to eql(
        { title: "Test Document", filename: "test", extension: "txt" }
      )
    end

    it "returns the correct filename" do
      expect(document.filename).to eql("test.txt")
    end
  end

  context "when a dynamically created document" do
    subject(:document) { described_class.new }

    it "returns the correct default filename" do
      expect(document.filename).to eql("index.html")
    end
  end
end
