# frozen_string_literal: true

describe 'Renderer' do
  subject { Dimples::Renderer.new(site, source) }

  let(:site) { double }
  let(:source) { double }

  before do
    allow(site).to receive(:config).and_return(Hashie::Mash.new(rendering: {}))
    allow(source).to receive(:metadata).and_return({})
  end

  describe '#render' do
    before do
      allow(source).to receive(:path).and_return('test.erb')
    end

    context 'when no options are passed in' do
      before do
        allow(source).to receive(:contents).and_return('Hello')
      end

      it 'correctly renders' do
        expect(subject.render).to eq('Hello')
      end
    end

    context 'when a context is passed in' do
      before do
        response = '<h1><%= page.title %></h1>'
        allow(source).to receive(:contents).and_return(response)
      end

      it 'correctly renders' do
        output = subject.render(page: Hashie::Mash.new(title: 'Welcome'))
        expect(output).to eq('<h1>Welcome</h1>')
      end
    end

    context 'when a context and body are passed in' do
      before do
        response = '<h1><%= page.title %></h1>\n<p><%= yield %></p>'
        allow(source).to receive(:contents).and_return(response)
      end

      it 'correctly renders' do
        output = subject.render(
          { page: Hashie::Mash.new(title: 'Welcome') },
          'Hey there'
        )

        expect(output).to eq('<h1>Welcome</h1>\n<p>Hey there</p>')
      end
    end
  end
end
