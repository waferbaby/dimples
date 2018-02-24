# frozen_string_literal: true

describe 'Page' do
  let(:site) { double }
  let(:page) { Dimples::Page.new(site, source_path) }
  let(:html) { '<p><em>Hey!</em></p>' }
  let(:source_path) { path = File.join(__dir__, 'sources', 'pages', 'index.markdown') }

  describe '#initialize' do
    context 'when a path is provided' do
      it 'parses the metadata and contents' do
        expect(page.contents).to eq('*Hey!*')
        expect(page.metadata).to eq(title: 'About', layout: false)
      end
    end

    context 'when no path is provided' do
      let(:page) { Dimples::Page.new(site) }

      it 'sets the default metadata and contents' do
        expect(page.contents).to eq('')
        expect(page.metadata).to eq({})
      end
    end
  end

  describe '#filename' do
    context 'with no filename provided in the metadata' do
      it 'returns the default filename' do
        expect(page.filename).to eq('index')
      end
    end

    context 'with a filename in the metadata' do
      before do
        page.metadata[:filename] = 'home'
      end

      it 'overrides the default value' do
        expect(page.filename).to eq('home')
      end
    end
  end

  describe '#extension' do
    context 'with no extension provided in the metadata' do
      it 'returns the default extension' do
        expect(page.extension).to eq('html')
      end
    end

    context 'with an extension in the metadata' do
      before do
        page.metadata[:extension] = 'txt'
      end

      it 'overrides the default value' do
        expect(page.extension).to eq('txt')
      end
    end
  end

  describe '#render' do
    context 'when the page has a path' do
      before do
        config = Hashie::Mash.new({ rendering: {} })
        allow(site).to receive(:config).and_return(config)
      end

      it 'renders the contents' do
        expect(page.render).to eq(html)
      end
    end

    context 'when the page has no path' do
      let(:page) { Dimples::Page.new(site) }

      it 'renders an empty string' do
        expect(page.render).to eq('')
      end
    end
  end

  describe '#write' do
    let(:output_directory) { File.join(@site_output, 'pages') }
    let(:output_path) { File.join(output_directory, "#{page.filename}.#{page.extension}") }

    before do
      allow(page).to receive(:render).and_return(html)
    end

    it 'writes out the file' do
      page.write(output_directory)

      expect(File.exist?(output_path)).to eq(true)
      expect(File.read(output_path)).to eq(html)
    end
  end
end
