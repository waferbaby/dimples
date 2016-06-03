$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Site' do
  subject { @site = test_site }

  describe 'building a complete site' do
    before { subject.generate }

    it 'prepares the output directory' do
      Dir.exist?(subject.output_paths[:site]).must_equal(true)
    end

    describe 'scanning for files' do
      it 'finds all the templates' do
        subject.templates.length.must_equal(7)
      end

      it 'finds all the pages' do
        subject.pages.length.must_equal(1)
      end

      it 'finds all the posts' do
        subject.posts.length.must_equal(2)
      end
    end

    describe 'generating files' do
      %w(year month day).each do |date_type|
        it 'generates #{date_type} archives' do
          expected_output = render_fixture("#{date_type}_archives.erb")

          paths = [subject.output_paths[:site], 'archives', '2015']
          paths << '01' if date_type =~ /month|day/
          paths << '01' if date_type == 'day'
          paths << 'index.html'

          file_path = File.join(paths)

          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal(expected_output)
        end
      end

      it 'generates categories' do
        subject.categories.keys.each do |slug|
          expected_output = render_fixture('categories.erb', slug: slug)
          categories_path = subject.output_paths[:categories]
          file_path = File.join(categories_path, slug, 'index.html')

          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal(expected_output)
        end
      end
    end
  end
end
