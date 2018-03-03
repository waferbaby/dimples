# frozen_string_literal: true

describe 'Post' do
  let(:site) { double }
  let(:post) { Dimples::Post.new(site, source_path) }
  let(:source_path) do
    File.join(__dir__, 'sources', 'posts', '2018-01-01-hello.markdown')
  end

  before do
    config = Hashie::Mash.new(layouts: { post: 'post' })
    allow(site).to receive(:config).and_return(config)
  end

  describe '#initialize' do
    it 'sets the post-specific metadata' do
      expect(post.metadata[:date]).to eq(Date.new(2018, 1, 1))
      expect(post.metadata[:slug]).to eq('hello')
      expect(post.metadata[:layout]).to eq('post')
      expect(post.metadata[:categories]).to eq(%w[personal dog])
    end
  end

  describe '#year' do
    it 'returns the correct value' do
      expect(post.year).to eq('2018')
    end
  end

  describe '#month' do
    it 'returns the correct value' do
      expect(post.month).to eq('01')
    end
  end

  describe '#day' do
    it 'returns the correct value' do
      expect(post.day).to eq('01')
    end
  end
end
