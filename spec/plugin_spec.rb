# frozen_string_literal: true

describe 'Plugin' do
  subject { Dimples::Plugin.new(site) }

  let(:site) { double }

  describe '.inherited' do
    context 'when a subclass of Plugin is included' do
      before do
        class TestPluginA < Dimples::Plugin; end
        class TestPluginB < Dimples::Plugin; end
      end

      it 'keeps a record of the subclass' do
        subclasses = Dimples::Plugin.subclasses
        expect(subclasses).to eq([TestPluginA, TestPluginB])
      end
    end
  end

  describe '#supports_event?' do
    context 'when a plugin supports no events' do
      it 'returns false for an event' do
        expect(subject.supports_event?(:before_site_generation)).to eq(false)
      end
    end

    context 'when a plugin supports a list of events' do
      before do
        allow(subject).to receive(:supported_events).and_return(
          [:before_site_generation]
        )
      end

      it 'returns true for an event' do
        expect(subject.supports_event?(:before_site_generation)).to eq(true)
      end
    end
  end
end
