# frozen_string_literal: true

describe Dimples::Metadata do
  subject(:metadata) { described_class.new(source) }
  let(:source) { {} }

  describe '#method_missing' do
    context 'with a key that matches a metadata key' do
      before { source[:sporks] = 12 }

      it 'returns the corresponding value' do
        expect(metadata.sporks).to be(12)
      end
    end

    context 'with a key that is not in the metadata' do
      it 'returns a nil value' do
        expect(metadata.spoons).to be_nil
      end
    end
  end
end
