# frozen_string_literal: true

describe Dimples::Post do
  subject(:post) { described_class.new(site: site, path: path) }

  let(:site) { double }
  let(:config) { double }
  let(:path) { File.expand_path(File.join('spec', 'fixtures', 'posts', 'my_post.markdown')) }
  let(:slug) { File.basename(path, File.extname(path)) }

  before do
    allow(site).to receive(:config).and_return(Dimples::Config.new)
  end

  describe '#output_directory' do
    it 'returns the correct path' do
      expect(post.output_directory).to eql(
        "#{File.join(File.dirname(post.path), slug)}/"
      )
    end
  end

  describe '#slug' do
    it 'returns the base name of the source path' do
      expect(post.slug).to eql(slug)
    end
  end
end
