# frozen_string_literal: true

describe 'Page' do
  subject { Dimples::Page.new(site, source_path) }

  let(:site) { double }
  let(:html) { '<p>I am a test website.</p>' }
  let(:source_path) do
    File.join(
      __dir__,
      'sources',
      'pages',
      'about',
      'index.markdown'
    )
  end

  before { allow(site).to receive(:templates).and_return({}) }

  describe '#initialize' do
    context 'when a path is provided' do
      it 'parses the metadata and contents' do
        expect(subject.contents).to eq('I am a test website.')
        expect(subject.metadata).to eq(title: 'About', layout: 'default')
      end
    end

    context 'when no path is provided' do
      subject { Dimples::Page.new(site) }

      it 'sets the default metadata and contents' do
        expect(subject.contents).to eq('')
        expect(subject.metadata).to eq({})
      end
    end
  end

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

    before { allow(subject).to receive(:render).and_return(html) }
    after { FileUtils.remove_dir(@site_output, force: true) }

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
      before { FileUtils.mkdir_p(@site_output, mode: 0o400) }
      after { FileUtils.remove_dir(@site_output, force: true) }

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

  describe '#method_missing' do
    context 'when accessing custom data via a method' do
      before { subject.metadata[:custom_data] = 'my_returned_data' }

      it 'returns its value' do
        expect(subject.custom_data).to eq('my_returned_data')
      end
    end

    context 'when setting custom data via a method' do
      before { subject.custom_data = 'my_set_data' }

      it 'stores a value' do
        expect(subject.metadata[:custom_data]).to eq('my_set_data')
      end
    end

    context 'when accessing unset custom data via a method' do
      it 'calls the super method' do
        expect { subject.unset_custom_data }.to raise_error(NoMethodError)
      end
    end
  end
end
