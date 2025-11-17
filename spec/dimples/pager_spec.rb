# frozen_string_literal: true

describe Dimples::Pager do
  subject(:pager) { Dimples::Pager.new(site:, url:, posts:) }

  let(:site) { double }
  let(:config) { double }
  let(:url) { "https://dimples.test/" }
  let(:posts) { [double, double, double] }

  before do
    allow(site).to receive(:config).and_return(config)
    allow(config).to receive(:pagination).and_return({ per_page: 1 })
  end

  describe '#step_to' do
    before { pager.step_to(page) }

    context 'for page 1' do
      let(:page) { 1 }

      it 'builds the correct context' do
        expect(pager.previous_page).to be_nil
        expect(pager.current_page).to eql(1)
        expect(pager.next_page).to eql(2)
      end
    end

    context 'for page 2' do
      let(:page) { 2 }

      it 'builds the correct context' do
        expect(pager.previous_page).to eql(1)
        expect(pager.current_page).to eql(2)
        expect(pager.next_page).to eql(3)
      end
    end

    context 'for page 3' do
      let(:page) { 3 }

      it 'builds the correct context' do
        expect(pager.previous_page).to eql(2)
        expect(pager.current_page).to eql(3)
        expect(pager.next_page).to be_nil
      end
    end
  end
end
