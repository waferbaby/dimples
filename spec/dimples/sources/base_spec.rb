# frozen_string_literal: true

describe Dimples::Sources::Base do
  subject(:base) { described_class.new(site:, path: file_path) }

  let(:site) { double }
  let(:file_path) { File.join(Dir.pwd, 'spec', 'fixtures', 'pages', 'index.erb') }

  describe '#parse_metadata' do
    it 'correctly parses the contents' do
      expect(base.metadata).to eql(filename: 'test.txt', title: 'Test Document', layout: nil)
    end

    it 'adds the metadata methods' do
      base.metadata.each_key do |method_name|
        expect(base).to respond_to(method_name)
      end
    end
  end
end
