# frozen_string_literal: true

describe 'Template' do
  subject { Dimples::Template.new(site, source_path) }

  let(:site) { double }
  let(:source_path) { File.join(__dir__, 'sources', 'templates', 'post.erb') }

  describe '#initialize' do
    it 'parses the metadata and contents' do
      expect(subject.contents).to eq('<article><%= yield %></article>')
      expect(subject.metadata).to eq(title: 'Post')
    end
  end

  describe '#render' do
    before do
      config = Hashie::Mash.new(rendering: {})
      allow(site).to receive(:config).and_return(config)
    end

    it 'renders the contents' do
      expect(subject.render({}, 'A post')).to eq('<article>A post</article>')
    end
  end
end
