# frozen_string_literal: true

describe 'Frontable' do
  include Dimples::Frontable

  describe '#read_with_front_matter' do
    context 'when a file has front matter' do
      let(:source_path) do
        File.join(__dir__, 'sources', 'pages', 'index.markdown')
      end

      it 'correctly parses the contents and metadata' do
        contents, metadata = read_with_front_matter(source_path)

        expect(contents).to eq('*Hey!*')
        expect(metadata).to eq(title: 'About', layout: false)
      end
    end

    context 'when a file has no front matter' do
      let(:source_path) { File.join(__dir__, 'sources', 'pages', 'info.txt') }

      it 'returns the contents without metadata' do
        contents, metadata = read_with_front_matter(source_path)

        expect(contents).to eq('I\'m just a text file.')
        expect(metadata).to eq({})
      end
    end
  end
end
