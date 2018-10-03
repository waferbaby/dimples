# frozen_string_literal: true

describe 'Frontable' do
  include Dimples::Frontable

  describe '#read_with_front_matter' do
    context 'with a file containing frontmatter' do
      let(:source_path) do
        File.join(__dir__, 'sources', 'pages', 'about', 'index.markdown')
      end

      it 'correctly parses the contents and metadata' do
        contents, metadata = read_with_front_matter(source_path)

        expect(contents).to eq('I am a test website.')
        expect(metadata).to eq(title: 'About', layout: 'default')
      end
    end

    context 'with a file containing no frontmatter' do
      let(:source_path) do
        File.join(__dir__, 'sources', 'templates', 'default.erb')
      end

      let(:raw_content) { File.read(source_path) }

      it 'reads in just the contents' do
        contents, metadata = read_with_front_matter(source_path)

        expect(contents).to eq(raw_content)
        expect(metadata).to eq({})
      end
    end
  end
end
