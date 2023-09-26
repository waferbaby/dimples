require "dimples"

describe Dimples::Site do
  subject(:site) { described_class.new(source_path, output_path, config) }

  let(:source_path) { File.join(__dir__, "fixtures") }
  let(:output_path) { File.join(__dir__, "my_site") }
  let(:config) { { overwrite_directory: true } }

  describe "#initialize" do
    context "with a custom config" do
      it "merges with the defaults" do
        expect(site.config).to eql(Dimples::Site::DEFAULT_CONFIG.merge(overwrite_directory: true))
      end
    end
  end

  describe "#scan_posts" do
    before { site.send(:scan_posts) }

    it "finds all posts" do
      expect(site.posts[0]).to be_a(Dimples::Post)
    end
  end

  context "#scan_pages" do
    before { site.send(:scan_pages) }

    it "finds them all" do
      expect(site.pages[0]).to be_a(Dimples::Page)
    end
  end
end
