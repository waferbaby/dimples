# frozen_string_literal: true

describe 'Page' do
  subject { Dimples::Page.new(site, source_path) }

  let(:site) { double }
  let(:html) { '<p><em>Hey!</em></p>' }
  let(:source_path) { File.join(__dir__, 'sources', 'pages', 'index.markdown') }

  describe '#filename' do
    context 'with no filename provided in the metadata' do
      it 'returns the default filename' do
        expect(subject.filename).to eq('index')
      end
    end

    context 'with a filename in the metadata' do
      before do
        subject.metadata[:filename] = 'home'
      end

      it 'overrides the default value' do
        expect(subject.filename).to eq('home')
      end
    end
  end

  describe '#extension' do
    context 'with no extension provided in the metadata' do
      it 'returns the default extension' do
        expect(subject.extension).to eq('html')
      end
    end

    context 'with an extension in the metadata' do
      before do
        subject.metadata[:extension] = 'txt'
      end

      it 'overrides the default value' do
        expect(subject.extension).to eq('txt')
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
        expect(subject.render).to eq(html)
      end
    end

    context 'when the page has no path' do
      subject { Dimples::Page.new(site) }

      it 'renders an empty string' do
        expect(subject.render).to eq('')
      end
    end
  end

  describe '#write' do
    let(:page_directory) { File.join(@site_output, 'pages') }

    before do
      allow(subject).to receive(:render).and_return(html)
    end

    context 'when we have correct permissions' do
      it 'writes out the file' do
        subject.write(page_directory)

        path = File.join(
          page_directory,
          "#{subject.filename}.#{subject.extension}"
        )

        expect(File.exist?(path)).to eq(true)
        expect(File.read(path)).to eq(html)
      end
    end

    context 'when we have incorrect permissions' do
      before do
        Dir.mkdir(@site_output, 0o400)
      end

      it 'raises an exception' do
        expect { subject.write(page_directory) }.to raise_error(
          Dimples::PublishingError
        )
      end
    end
  end

  describe '#inspect' do
    it 'shows the correct string' do
      expect(subject.inspect).to eq("#<Dimples::Page @path=#{subject.path}>")
    end
  end
end
