# frozen_string_literal: true

describe 'Site' do
  subject { Dimples::Site.new(config) }

  let(:config) do
    {
      source: File.join(__dir__, 'sources'),
      destination: File.join(@site_output, 'public')
    }
  end

  describe '#data' do
    context 'with no custom data' do
      it 'returns an empty hash' do
        expect(subject.data).to eq({})
      end
    end

    context 'with custom data' do
      before { config[:data] = Hashie::Mash.new(description: 'A test website') }

      it 'returns the correct values' do
        expect(subject.data.description).to eq('A test website')
      end
    end
  end

  describe '#read_templates' do
    before { subject.send(:read_templates) }

    it 'finds all the source files' do
      expect(subject.templates.count).to eq(3)
      expect(subject.templates.keys.sort).to eq(
        %w[default post shared.header].sort
      )

      subject.templates.each_value do |template|
        expect(template).to be_a(Dimples::Template)
      end
    end
  end

  describe '#read_posts' do
    before { subject.send(:read_posts) }

    it 'finds all the source files' do
      expect(subject.posts.count).to eq(2)

      subject.posts.each do |page|
        expect(page).to be_a(Dimples::Post)
      end
    end
  end

  describe '#read_pages' do
    before { subject.send(:read_pages) }

    it 'finds all the source files' do
      expect(subject.pages.count).to eq(1)

      subject.pages.each do |page|
        expect(page).to be_a(Dimples::Page)
      end
    end
  end

  describe '#create_output_directory' do
    context 'when permissions are correct' do
      before { subject.send(:create_output_directory) }
      after { FileUtils.remove_dir(@site_output, force: true) }

      it 'creates the directory' do
        expect(Dir.exist?(subject.paths[:destination])).to be_truthy
      end
    end

    context 'when permissions are incorrect' do
      before { FileUtils.mkdir_p(@site_output, mode: 0o400) }
      after { FileUtils.remove_dir(@site_output, force: true) }

      it 'raises an exception' do
        expect { subject.send(:create_output_directory) }.to raise_error(
          Dimples::GenerationError
        )
      end
    end
  end

  describe '#copy_static_assets' do
    before do
      FileUtils.mkdir_p(subject.paths[:destination])
      subject.send(:copy_static_assets)
    end

    it 'copies all assets into the correct directory' do
      source_files = Dir.glob(
        File.join(subject.paths[:static], '**', '*.*')
      )

      destination_files = Dir.glob(
        File.join(subject.paths[:static], '**', '*.*')
      )

      expect(source_files.sort).to eq(destination_files.sort)
    end
  end

  describe '#inspect' do
    it 'shows the correct string' do
      expect(subject.inspect).to eq("#<Dimples::Site @paths=#{subject.paths}>")
    end
  end
end
