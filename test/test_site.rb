# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Site' do
  describe 'when generating a site' do
    before { test_site.generate }

    it 'finds all the templates' do
      path = File.join(test_site.source_paths[:templates], '**', '*.*')
      test_site.templates.length.must_equal(Dir.glob(path).length)
    end

    it 'finds all the pages' do
      path = File.join(test_site.source_paths[:pages], '**', '*.*')
      test_site.pages.length.must_equal(Dir.glob(path).length)
    end

    it 'finds all the posts' do
      path = File.join(test_site.source_paths[:posts], '*.*')
      test_site.posts.length.must_equal(Dir.glob(path).length)
    end

    it 'creates the output directory' do
      File.directory?(test_site.output_paths[:site]).must_equal(true)
    end

    it 'prepares the archive data' do
      years = test_site.posts.map { |post| post.year }.uniq.sort
      test_site.archives[:year].keys.sort.must_equal(years)

      months = test_site.posts.map do |post|
        "#{post.year}/#{post.month}"
      end.uniq.sort

      test_site.archives[:month].keys.sort.must_equal(months)

      days = test_site.posts.map do |post|
        "#{post.year}/#{post.month}/#{post.day}"
      end.uniq.sort

      test_site.archives[:day].keys.sort.must_equal(days)
    end

    %w[year month day].each do |date_type|
      it "creates the #{date_type} archives" do
        expected_output = read_fixture("archives/#{date_type}")

        paths = [test_site.output_paths[:site], 'archives', '2015']
        paths << '01' if date_type.match?(/month|day/)
        paths << '01' if date_type == 'day'
        paths << 'index.html'

        file_path = File.join(paths)

        File.exist?(file_path).must_equal(true)
        File.read(file_path).must_equal(expected_output)
      end
    end

    it 'creates categories' do
      test_site.categories.keys.each do |slug|
        expected_output = read_fixture("categories/#{slug}")
        categories_path = test_site.output_paths[:categories]
        file_path = File.join(categories_path, slug, 'index.html')

        File.exist?(file_path).must_equal(true)
        File.read(file_path).must_equal(expected_output)
      end
    end

    it 'copies over all the assets' do
      path = File.join(test_site.source_paths[:public], '**', '*')

      Dir.glob(path).each do |asset_path|
        output_path = asset_path.gsub(
          test_site.source_paths[:public],
          test_site.output_paths[:site]
        )

        File.exist?(output_path).must_equal(true)
      end

    end
  end
end
