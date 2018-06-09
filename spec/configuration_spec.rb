# frozen_string_literal: true

describe 'Configuration' do
  describe '.defaults' do
    let(:defaults) { Dimples::Configuration.defaults }

    it 'returns the default paths' do
      expect(defaults[:source]).to eq(File.expand_path('./'))
      expect(defaults[:destination]).to eq(File.expand_path('./public'))

      expect(defaults[:paths][:archives]).to eq('archives')
      expect(defaults[:paths][:posts]).to eq('archives/%Y/%m/%d')
      expect(defaults[:paths][:categories]).to eq('archives/categories')
    end

    it 'returns the default generation options' do
      generation_types = %i[
        archives
        year_archives
        month_archives
        day_archives
        categories
        main_feed
        category_feeds
      ]

      generation_types.each do |type|
        expect(defaults[:generation][type]).to be_truthy
      end
    end

    it 'returns the default layouts' do
      expect(defaults[:layouts][:post]).to eq('post')
      expect(defaults[:layouts][:category]).to eq('category')
      expect(defaults[:layouts][:archive]).to eq('archive')
      expect(defaults[:layouts][:date_archive]).to eq('archive')
    end

    it 'returns the default date formats' do
      expect(defaults[:date_formats][:year]).to eq('%Y')
      expect(defaults[:date_formats][:month]).to eq('%Y-%m')
      expect(defaults[:date_formats][:day]).to eq('%Y-%m-%d')
    end

    it 'returns the default feed formats' do
      expect(defaults[:feed_formats]).to eq(['atom'])
    end

    it 'returns the default pagination options' do
      expect(defaults[:pagination][:page_prefix]).to eq('page')
      expect(defaults[:pagination][:per_page]).to eq(10)
    end
  end
end
