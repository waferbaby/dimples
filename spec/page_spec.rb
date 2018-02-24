# frozen_string_literal: true

describe 'Page' do
  let(:site) { double }
  let(:page) { Dimples::Page.new(site) }

  describe '#initialize' do
    context 'when a path is provided' do
      let(:path) { './pages/about.erb' }
      let(:page) { Dimples::Page.new(site, path) }

      before do
        page_data = <<PAGE_DATA
---
title: About
layout: default
---

Hello.
PAGE_DATA

        allow(File).to receive(:read).with(path).and_return(page_data)
      end

      it 'parses the metadata and contents' do
        expect(page.contents).to eq('Hello.')
        expect(page.metadata).to eq(title: 'About', layout: 'default')
      end
    end

    context 'when no path is provided' do
      it 'sets the default metadata and contents' do
        expect(page.contents).to eq('')
        expect(page.metadata).to eq({})
      end
    end
  end

  describe '#filename' do
    context 'with no filename provided in the metadata' do
      it 'returns the default filename' do
        expect(page.filename).to eq('index')
      end
    end

    context 'with a filename in the metadata' do
      before do
        page.metadata[:filename] = 'home'
      end

      it 'overrides the default value' do
        expect(page.filename).to eq('home')
      end
    end
  end

  describe '#extension' do
    context 'with no extension provided in the metadata' do
      it 'returns the default extension' do
        expect(page.extension).to eq('html')
      end
    end

    context 'with an extension in the metadata' do
      before do
        page.metadata[:extension] = 'txt'
      end

      it 'overrides the default value' do
        expect(page.extension).to eq('txt')
      end
    end
  end

  describe '#render' do
  end

  describe '#write' do
  end
end
