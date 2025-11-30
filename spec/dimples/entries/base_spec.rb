# frozen_string_literal: true

describe Dimples::Entries::Base do
  subject(:base) { described_class.new(site: site, contents: contents) }

  let(:site) { double }
  let(:contents) { "HEY!\n\nI am content!" }

  describe '#parse_metadata' do
    it 'correctly parses the contents' do
      expect(base.metadata).to eql({ filename: 'index.html', layout: nil })
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

  describe '#method_missing' do
    context 'with a key that matches a metadata key' do
      let(:contents) do
        <<~METADATA
          ---
          sporks: 12
          ---

          I love sporks!
        METADATA
      end

      it 'returns the corresponding value' do
        expect(base.sporks).to be(12)
      end
    end

    context 'with a key that is not in the metadata' do
      it 'returns a nil value' do
        expect(base.spoons).to be_nil
      end
    end
  end
end
