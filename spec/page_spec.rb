# frozen_string_literal: true

describe 'Page' do
  let(:site) { double }
  let(:page) { Dimples::Page.new(site, source_path) }
  let(:html) { '<p><em>Hey!</em></p>' }
  let(:source_path) { File.join(__dir__, 'sources', 'pages', 'index.markdown') }

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
        config = Hashie::Mash.new(rendering: {})
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
    let(:page_directory) { File.join(@site_output, 'pages') }

    before do
      allow(page).to receive(:render).and_return(html)
    end

    context 'when we have correct permissions' do
      it 'writes out the file' do
        page.write(page_directory)

        path = File.join(page_directory, "#{page.filename}.#{page.extension}")

        expect(File.exist?(path)).to eq(true)
        expect(File.read(path)).to eq(html)
      end
    end

    context 'when we have incorrect permissions' do
      before do
        Dir.mkdir(@site_output, 0o400)
      end

      it 'raises an exception' do
        expect { page.write(page_directory) }.to raise_error(
          Dimples::PublishingError
        )
      end
    end
  end

  describe '#inspect' do
    context 'when a path is provided' do
      it 'shows the correct string' do
        expect(page.inspect).to eq("#<Dimples::Page @path=#{page.path}>")
      end
    end

    context 'when no path is provided' do
      let(:page) { Dimples::Page.new(site) }

      it 'shows the correct string' do
        expect(page.inspect).to eq('#<Dimples::Page @path=>')
      end
    end
  end
end
