# frozen_string_literal: true

describe 'Site' do
  subject { Dimples::Site.new(config) }

  let(:config) do
    {
      source: File.join(__dir__, 'sources'),
      destination: File.join(@site_output, 'public')
    }
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
