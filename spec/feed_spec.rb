# frozen_string_literal: true

describe 'Feed' do
  subject { Dimples::Feed.new(site, 'atom') }

  let(:site) { double }

  describe '#initialize' do
    it 'sets the correct values for the feed' do
      expect(subject.filename).to eq('feed')
      expect(subject.extension).to eq('atom')
      expect(subject.layout).to eq('feeds.atom')
    end
  end
end
