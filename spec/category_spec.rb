# frozen_string_literal: true

describe 'Category' do
  subject { Dimples::Category.new(site, 'mac') }

  let(:site) { double }
  let(:config) { Hashie::Mash.new(category_names: {}) }

  before { allow(site).to receive(:config).and_return(config) }

  describe '#initialize' do
    context 'when no custom category name exists' do
      it 'uses the slug as the name' do
        expect(subject.slug).to eq('mac')
        expect(subject.name).to eq('Mac')
      end
    end

    context 'when a custom category name exists' do
      before { config.category_names[:mac] = 'Macintosh' }

      it 'uses the name instead of the slug' do
        expect(subject.slug).to eq('mac')
        expect(subject.name).to eq('Macintosh')
      end
    end
  end
end
