# frozen_string_literal: true

describe 'Archive' do
  subject { Dimples::Archive.new }
  let(:post) { double }

  before do
    allow(post).to receive(:year).and_return('2018')
    allow(post).to receive(:month).and_return('01')
    allow(post).to receive(:day).and_return('01')

    subject.add_post(post)
  end

  describe '#years' do
    it 'returns the correct values' do
      expect(subject.years).to eq(['2018'])
    end
  end

  describe '#months' do
    it 'returns the correct values' do
      expect(subject.months(2018)).to eq(['01'])
    end
  end

  describe '#days' do
    it 'returns the correct values' do
      expect(subject.days('2018', '01')).to eq(['01'])
    end
  end

  describe '#posts_for_date' do
    context 'when passing in a year' do
      it 'returns the correct posts' do
        expect(subject).to receive(:year_posts).with('2018')
        subject.posts_for_date('2018')
      end
    end

    context 'when passing in a year and month' do
      it 'returns the correct posts' do
        expect(subject).to receive(:month_posts).with('2018', '01')
        subject.posts_for_date('2018', '01')
      end
    end

    context 'when passing in a year, month and day' do
      it 'returns the correct posts' do
        expect(subject).to receive(:day_posts).with('2018', '01', '01')
        subject.posts_for_date('2018', '01', '01')
      end
    end
  end

  describe '#year_posts' do
    it 'returns the correct posts' do
      expect(subject.year_posts('2018')).to eq([post])
    end
  end

  describe '#month_posts' do
    it 'returns the correct posts' do
      expect(subject.month_posts('2018', '01')).to eq([post])
    end
  end

  describe '#day_posts' do
    it 'returns the correct posts' do
      expect(subject.day_posts('2018', '01', '01')).to eq([post])
    end
  end
end
