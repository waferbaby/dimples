# frozen_string_literal: true

describe 'Site' do
  subject { Dimples::Site.new(config) }

  let(:config) { { source: File.join(__dir__, 'sources') } }

  describe '#read_templates' do
    before { subject.send(:read_templates) }

    it 'finds all the source files' do
      expect(subject.templates.count).to eq(3)
      expect(subject.templates.keys.sort).to eq(
        %w[default post shared.header].sort
      )

      subject.templates.each_value do |template|
        expect(template).to be_a(Dimples::Template)
      end
    end
  end

  describe '#read_posts' do
    before { subject.send(:read_posts) }

    it 'finds all the source files' do
      expect(subject.posts.count).to eq(2)

      subject.posts.each do |page|
        expect(page).to be_a(Dimples::Post)
      end
    end
  end

  describe '#read_pages' do
    before { subject.send(:read_pages) }

    it 'finds all the source files' do
      expect(subject.pages.count).to eq(1)

      subject.pages.each do |page|
        expect(page).to be_a(Dimples::Page)
      end
    end
  end

  describe '#create_output_directory' do
    before { FileUtils.remove_dir(subject.paths[:destination]) }

    context 'when no directory already exists' do
      before { subject.send(:create_output_directory) }

      it 'creates the directory' do
        expect(Dir.exist?(subject.paths[:destination])).to be_truthy
      end
    end
  end

  describe '#inspect' do
    it 'shows the correct string' do
      expect(subject.inspect).to eq("#<Dimples::Site @paths=#{subject.paths}>")
    end
  end
end
