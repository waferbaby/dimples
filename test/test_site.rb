# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Site do
  describe 'when scanning files' do
    before { test_site.scan_files }

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

    it 'prepares the archive data' do
      years = test_site.posts.map(&:year).uniq.sort
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
  end

  describe 'when generating the complete site' do
    before { test_site.generate }

    it 'prepares the output directory' do
      File.directory?(test_site.output_paths[:site]).must_equal(true)
    end

    it 'copies all the asset files' do
      path = File.join(test_site.source_paths[:public], '**', '*')

      Dir.glob(path).each do |asset_path|
        output_path = asset_path.gsub(
          test_site.source_paths[:public],
          test_site.output_paths[:site]
          )

        File.exist?(output_path).must_equal(true)
      end
    end

    after { clean_generated_site }
  end

  describe 'when generating archives' do
    before { test_site.scan_files }

    %w[year month day].each do |date_type|
      describe "with #{date_type} generation enabled" do
        before do
          test_site.config['generation']["#{date_type}_archives"] = true
          test_site.generate_archives
        end

        it 'creates the archive index files' do
          archive_file_paths(date_type.to_sym).each do |date, path|
            expected_output = read_fixture("pages/archives/#{date}")

            File.exist?(path).must_equal(true)
            File.read(path).must_equal(expected_output)
          end
        end

        after { clean_generated_site }
      end

      describe "with #{date_type} generation disabled" do
        before do
          test_site.config['generation']["#{date_type}_archives"] = false
          test_site.generate_archives
        end

        it 'creates no archive index files' do
          archive_file_paths(date_type.to_sym).each do |_, path|
            File.exist?(path).must_equal(false)
          end
        end

        after { clean_generated_site }
      end
    end
  end
end
