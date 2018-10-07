# frozen_string_literal: true

describe 'Site' do
  subject { Dimples::Site.new(config) }

  let(:config) do
    {
      source: File.join(__dir__, 'sources'),
      destination: File.join(@site_output, 'public')
    }
  end

  describe '#generate' do
    context 'when successfully generating a site' do
      before { subject.generate }

      it 'creates the output directory' do
        expect(Dir.exist?(subject.paths[:destination])).to be_truthy
      end

      it 'copies the static assets' do
        Dir.glob(File.join(subject.paths[:static], '**', '*.*')).each do |path|
          copied_path = path.sub(
            subject.paths[:static],
            subject.paths[:destination]
          )

          expect(File.exist?(copied_path)).to be_truthy
          expect(File.read(path)).to eq(File.read(copied_path))
        end
      end

      it 'publishes all the posts' do
        subject.posts.each do |post|
          post_path = File.join(
            subject.paths[:destination],
            post.date.strftime(subject.config.paths.posts),
            post.slug,
            'index.html'
          )

          expect(File.exist?(post_path)).to be_truthy
        end
      end

      it 'publishes all the pages' do
        subject.pages.each do |page|
          page_path = File.join(
            File.dirname(page.path).sub(
              subject.paths[:pages],
              subject.paths[:destination]
            ),
            'index.html'
          )

          expect(File.exist?(page_path)).to be_truthy
        end
      end
    end
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

  describe '#inspect' do
    it 'shows the correct string' do
      expect(subject.inspect).to eq("#<Dimples::Site @paths=#{subject.paths}>")
    end
  end
end
