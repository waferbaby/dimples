# frozen_string_literal: true

describe Dimples::Entries::Base do
  subject(:base) { described_class.new(site: site, source: contents) }

  let(:site) { double }
  let(:body) { "HEY!\n\nI am content!" }
  let(:contents) { body }
  let(:layouts) { {} }

  before do
    allow(site).to receive(:metadata).and_return({})
    allow(site).to receive(:layouts).and_return(layouts)
  end

  describe '#parse_metadata' do
    it 'correctly parses the contents' do
      expect(base.metadata.to_h).to eql({ filename: 'index.html', layout: nil })
    end
  end

  describe '#write' do
    let(:path) { File.join(Dir.tmpdir, 'dimples-test-file') }

    before do
      allow(site).to receive(:metadata).and_return({})

      base.write(output_path: path)
    end

    it 'create the file at the correct location' do
      expect(File.exist?(path)).to be(true)
    end

    it 'writes the correct file contents' do
      expect(File.read(path)).to eql(contents)
    end
  end

  describe '#render' do
    context 'with default params' do
      it 'renders the expected output' do
        expect(base.render).to eql(contents)
      end
    end

    context 'with a layout' do
      let(:layouts) { { test: Dimples::Entries::Base.new(site: site, source: template) } }
      let(:template) { "<em><%= yield %></em>" }
      let(:contents) { "---\nlayout: test\n---\n\n#{body}"}

      it 'renders with the layout around its contents' do
        expect(base.render).to eql("<em>#{body}</em>")
      end
    end
  end
end
