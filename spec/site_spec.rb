# frozen_string_literal: true

describe 'Site' do
  subject { Dimples::Site.new(config) }

  let(:config) { { source: File.join(__dir__, 'sources') } }

  describe '#generate' do
    before { subject.generate }

    it 'finds all the templates' do
      expect(subject.templates.count).to eq(3)
      expect(subject.templates.keys.sort).to eq(
        %w[default post shared.header].sort
      )

      subject.templates.each_value do |template|
        expect(template).to be_a(Dimples::Template)
      end
    end

    it 'finds all the posts' do
      expect(subject.posts.count).to eq(2)

      subject.posts.each do |page|
        expect(page).to be_a(Dimples::Post)
      end
    end

    it 'finds all the pages' do
      subject.send(:read_pages)

      expect(subject.pages.count).to eq(1)

      subject.pages.each do |page|
        expect(page).to be_a(Dimples::Page)
      end
    end
  end
end
