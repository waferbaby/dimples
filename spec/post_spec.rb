# frozen_string_literal: true

describe 'Post' do
  subject { Dimples::Post.new(site, source_path) }

  let(:site) { double }
  let(:source_path) do
    File.join(__dir__, 'sources', 'posts', '2018-01-01-hello.markdown')
  end

  before do
    config = Hashie::Mash.new(layouts: { post: 'post' })
    allow(site).to receive(:config).and_return(config)
  end

  describe '#initialize' do
    it 'sets the post-specific metadata' do
      expect(subject.metadata[:date]).to eq(Date.new(2018, 1, 1))
      expect(subject.metadata[:slug]).to eq('hello')
      expect(subject.metadata[:layout]).to eq('post')
      expect(subject.metadata[:categories]).to eq(%w[personal dog])
    end
  end

  describe '#year' do
    it 'returns the correct value' do
      expect(subject.year).to eq('2018')
    end
  end

  describe '#month' do
    it 'returns the correct value' do
      expect(subject.month).to eq('01')
    end
  end

  describe '#day' do
    it 'returns the correct value' do
      expect(subject.day).to eq('01')
    end
  end
end
