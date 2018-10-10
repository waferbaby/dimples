# frozen_string_literal: true

describe 'Site' do
  subject { Dimples::Site.new(config) }

  let(:paths) do
    {
      source: File.join(__dir__, 'sources'),
      destination: File.join(@site_output, 'public')
    }
  end

  let(:config) { paths }

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

      %w[year month day].each do |type|
        context "when considering #{type} archives" do
          let(:archive_paths) do
            dates = case type
                    when 'year'
                      subject.archive.years
                    when 'month'
                      subject.archive.years.flat_map do |year|
                        [year] + subject.archive.months(year)
                      end
                    when 'day'
                      subject.archive.years.flat_map do |year|
                        subject.archive.months(year).flat_map do |month|
                          [year, month] + subject.archive.days(year, month)
                        end
                      end
                    end

            [].tap do |paths|
              paths << File.join(
                subject.paths[:destination],
                subject.config.paths.archives,
                dates,
                'index.html'
              )
            end
          end

          context "if #{type} generation is enabled" do
            it "generates the #{type} pages" do
              archive_paths.each do |path|
                expect(File.exist?(path)).to be_truthy
              end
            end
          end

          context "if #{type} generation is disabled" do
            let(:config) do
              paths.merge(generation: { "#{type}_archives": false })
            end

            it "generates no #{type} pages" do
              archive_paths.each do |path|
                expect(File.exist?(path)).to be_falsey
              end
            end
          end
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
