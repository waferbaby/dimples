describe Dimples::Sources::Base do
  subject(:base) { described_class.new(site, file_path) }

  let(:site) { double }
  let(:file_path) { File.join(Dir.pwd, 'spec', 'fixtures', 'pages', 'index.markdown') }

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
