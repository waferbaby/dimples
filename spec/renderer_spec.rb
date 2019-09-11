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
    before { allow(source).to receive(:path).and_return('test.erb') }

    context 'when no options are passed in' do
      before { allow(source).to receive(:contents).and_return('Hello') }

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

    context 'when a layout is defined' do
      let(:template) { double('code', render: 'The code is 12345.') }

      before do
        source.metadata[:layout] = 'code'

        allow(site).to receive(:templates).and_return('code' => template)
        allow(source).to receive(:contents).and_return('Hello')
      end

      it 'renders the template' do
        expect(template).to receive(:render)
        subject.render
      end

      context 'when an invalid source is used' do
        before { allow(source).to receive(:contents).and_return('<%= x %>') }

        it 'raises a rendering exception' do
          expect { subject.render }.to raise_error(Dimples::RenderingError)
        end
      end
    end
  end
end
