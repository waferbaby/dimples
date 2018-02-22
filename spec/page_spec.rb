describe 'Page' do
  let(:site) { double }

  describe '#initialize' do
    context 'when a path is provided' do
      let(:page) { Dimples::Page.new(site, './pages/about.erb') }

      before do
        page_data = <<PAGE_DATA
---
title: About
layout: default
---

Hello.
PAGE_DATA

        allow(File).to receive(:read).with('./pages/about.erb').and_return(page_data)
      end

      it 'parses the metadata and contents' do
        expect(page.contents).to eq('Hello.')
        expect(page.metadata).to eq({ title: 'About', layout: 'default' })
      end
    end

    context 'when no path is provided' do
      let(:page) { Dimples::Page.new(site) }

      it 'sets the default metadata and contents' do
        expect(page.contents).to eq('')
        expect(page.metadata).to eq({})
      end
    end
  end
end