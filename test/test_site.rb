# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Site' do
  describe 'building a site' do
    before { test_site.generate }

    it 'creates the output directory' do
      File.directory?(test_site.output_paths[:site]).must_equal(true)
    end

    describe 'scanning for files' do
      it 'finds all the templates' do
        test_site.templates.length.must_equal(7)
      end

      it 'finds all the pages' do
        test_site.pages.length.must_equal(2)
      end

      it 'finds all the posts' do
        test_site.posts.length.must_equal(2)
      end
    end

    describe 'generating files' do
      %w[year month day].each do |date_type|
        it "generates #{date_type} archives" do
          expected_output = render_template("#{date_type}_archives")

          paths = [test_site.output_paths[:site], 'archives', '2015']
          paths << '01' if date_type.match?(/month|day/)
          paths << '01' if date_type == 'day'
          paths << 'index.html'

          file_path = File.join(paths)

          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal(expected_output)
        end
      end

      it 'generates categories' do
        test_site.categories.keys.each do |slug|
          expected_output = render_template('categories', slug: slug)
          categories_path = test_site.output_paths[:categories]
          file_path = File.join(categories_path, slug, 'index.html')

          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal(expected_output)
        end
      end
    end
  end
end
