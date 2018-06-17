# frozen_string_literal: true

describe 'Frontable' do
  include Dimples::Frontable

  describe '#read_with_front_matter' do
    let(:source_path) do
      File.join(__dir__, 'sources', 'pages', 'about', 'index.markdown')
    end

    it 'correctly parses the contents and metadata' do
      contents, metadata = read_with_front_matter(source_path)

      expect(contents).to eq('I am a test website.')
      expect(metadata).to eq(title: 'About', layout: 'default')
    end
  end
end
