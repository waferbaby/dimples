# frozen_string_literal: true

describe 'FrontMatter' do
  describe '.parse' do
    subject { Dimples::FrontMatter.parse(data) }

    context 'with data containing frontmatter' do
      let(:data) do
        File.read(
          File.join(__dir__, 'sources', 'pages', 'about', 'index.markdown')
        )
      end

      it 'correctly parses the contents and metadata' do
        contents, metadata = subject

        expect(contents).to eq('I am a test website.')
        expect(metadata).to eq(title: 'About', layout: 'default')
      end
    end

    context 'with data containing no frontmatter' do
      let(:data) do
        File.read(
          File.join(__dir__, 'sources', 'templates', 'default.erb')
        )
      end

      it 'reads in just the contents' do
        contents, metadata = subject

        expect(contents).to eq(data)
        expect(metadata).to eq({})
      end
    end
  end
end
