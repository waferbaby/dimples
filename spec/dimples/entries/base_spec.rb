# frozen_string_literal: true

describe Dimples::Entries::Base do
  subject(:entry) { described_class.new(site: site, contents: contents) }

  let(:site) { double }
  let(:contents) { 'I am content!' }

  describe '#parse_metadata' do
    it 'correctly parses the contents' do
      expect(entry.metadata).to eql({ filename: 'index.html', layout: nil })
    end

    it 'adds the metadata methods' do
      entry.metadata.each_key do |method_name|
        expect(entry).to respond_to(method_name)
      end
    end
  end
end
