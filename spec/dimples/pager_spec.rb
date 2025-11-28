# frozen_string_literal: true

describe Dimples::Pager do
  subject(:pager) { described_class.new(site: site, url: url, posts: posts) }

  let(:site) { double }
  let(:config) { double }
  let(:url) { 'https://dimples.test/' }
  let(:posts) { [double, double, double] }

  before do
    allow(site).to receive(:config).and_return(config)
    allow(config).to receive(:pagination).and_return({ per_page: 1 })
  end

  describe '#step_to' do
    before { pager.step_to(page) }

    context 'when at page 1' do
      let(:page) { 1 }

      it 'builds the correct context' do
        expect([pager.previous_page, pager.current_page, pager.next_page]).to eq([nil, 1, 2])
      end
    end

    context 'when at page 2' do
      let(:page) { 2 }

      it 'builds the correct context' do
        expect([pager.previous_page, pager.current_page, pager.next_page]).to eq([1, 2, 3])
      end
    end

    context 'when at page 3' do
      let(:page) { 3 }

      it 'builds the correct context' do
        expect([pager.previous_page, pager.current_page, pager.next_page]).to eq([2, 3, nil])
      end
    end
  end
end
