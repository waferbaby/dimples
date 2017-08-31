# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'
require 'timecop'

describe Dimples::Site do
  it 'returns the correct value when inspected' do
    test_site.inspect.must_equal(
      '#<Dimples::Site ' \
      "@source_paths=#{test_site.source_paths} " \
      "@output_paths=#{test_site.output_paths}>"
    )
  end

  describe 'when generating' do
    describe 'with default settings' do
      before do
        Timecop.freeze(Time.local(2017, 1, 1, 0, 0, 0))
        test_site.generate
        Timecop.return
      end

      %w[templates pages posts].each do |file_type|
        it "finds all the #{file_type} files" do
          file_type_sym = file_type.to_sym

          glob_path = File.join(
            test_site.source_paths[file_type_sym],
            '**',
            '*.*'
          )

          length = Dir.glob(glob_path).length

          test_site.send(file_type_sym).length.must_equal(length)
        end
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

      it 'prepares the output directory' do
        File.directory?(test_site.output_paths[:site]).must_equal(true)
      end

      it 'creates all the posts' do
        test_site.posts.each do |post|
          fixture = "posts/#{post.year}-#{post.month}-#{post.day}-#{post.slug}"

          File.exist?(post.output_path).must_equal(true)
          compare_file_to_fixture(post.output_path, fixture)
        end
      end

      it 'creates all the posts feeds' do
        site_feed_template_types.each do |feed_type|
          expected_output = read_fixture("pages/feeds/#{feed_type}_posts")

          file_path = File.join(
            test_site.output_paths[:site],
            "feed.#{feed_type}"
          )

          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal(expected_output)
        end
      end

      it 'creates all the main pages' do
        test_site.pages.each do |page|
          directory = File.dirname(page.output_path).gsub(
            test_site.output_paths[:site],
            ''
          )

          filename = File.basename(page.output_path, '.html')
          fixture = "pages/general#{directory}/#{filename}"

          File.exist?(page.output_path).must_equal(true)
          compare_file_to_fixture(page.output_path, fixture)
        end
      end

      %w[year month day].each do |date_type|
        it "creates the #{date_type} archives" do
          archive_file_paths(date_type.to_sym).each do |date, file_path|
            expected_output = read_fixture("pages/archives/#{date}")

            File.exist?(file_path).must_equal(true)
            File.read(file_path).must_equal(expected_output)
          end
        end
      end

      it 'creates all the category pages' do
        categories_path = test_site.output_paths[:categories]

        test_site.categories.keys.each do |slug|
          expected_output = read_fixture("pages/categories/#{slug}")
          file_path = File.join(categories_path, slug, 'index.html')

          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal(expected_output)
        end
      end

      it 'creates all the category feeds' do
        categories_path = test_site.output_paths[:categories]

        test_site.categories.keys.each do |slug|
          site_feed_template_types.each do |feed_type|
            fixture = "pages/feeds/#{slug}_#{feed_type}_posts"
            expected_output = read_fixture(fixture)
            file_path = File.join(categories_path, slug, "feed.#{feed_type}")

            File.exist?(file_path).must_equal(true)
            File.read(file_path).must_equal(expected_output)
          end
        end
      end

      it 'copies all the asset files' do
        glob_path = File.join(test_site.source_paths[:public], '**', '*')

        Dir.glob(glob_path).each do |asset_path|
          file_path = asset_path.gsub(
            test_site.source_paths[:public],
            test_site.output_paths[:site]
          )

          File.exist?(file_path).must_equal(true)
        end
      end

      after { clean_generated_site }
    end

    describe 'with custom settings' do
      describe 'if the main feeds are disabled' do
        before do
          test_site.config['generation']['feeds'] = false
          test_site.generate
        end

        it 'creates none of the feeds' do
          site_feed_template_types.each do |feed_type|
            file_path = File.join(
              test_site.output_paths[:site],
              "feed.#{feed_type}"
            )

            File.exist?(file_path).must_equal(false)
          end
        end

        after { clean_generated_site }
      end

      %w[year month day].each do |date_type|
        describe "if #{date_type} generation is disabled" do
          before do
            test_site.config['generation']["#{date_type}_archives"] = false
            test_site.scan_files
            test_site.generate_archives
          end

          it 'creates no archive files' do
            archive_file_paths(date_type.to_sym).each do |_, path|
              File.exist?(path).must_equal(false)
            end
          end

          after { clean_generated_site }
        end
      end

      describe 'if category generation is disabled' do
        before do
          test_site.config['generation']['categories'] = false
          test_site.generate
        end

        it 'creates none of the category files' do
          test_site.categories.keys.each do |slug|
            categories_path = test_site.output_paths[:categories]
            file_path = File.join(categories_path, slug, 'index.html')

            File.exist?(file_path).must_equal(false)
          end
        end

        after { clean_generated_site }
      end

      describe 'if category feed generation is disabled' do
        before do
          test_site.config['generation']['category_feeds'] = false
          test_site.generate
        end

        it 'creates no category feeds' do
          test_site.categories.keys.each do |slug|
            categories_path = test_site.output_paths[:categories]

            site_feed_template_types.each do |feed_type|
              file_path = File.join(categories_path, slug, "feed.#{feed_type}")
              File.exist?(file_path).must_equal(false)
            end
          end
        end

        after { clean_generated_site }
      end

      describe 'with custom category names' do
        before do
          test_site.config['category_names']['green'] = 'G R E E N'
          test_site.generate
        end

        it 'uses the name correctly' do
          expected_output = read_fixture('pages/categories/custom_green')
          categories_path = test_site.output_paths[:categories]
          file_path = File.join(categories_path, 'green', 'index.html')

          File.read(file_path).must_equal(expected_output)
        end

        after { clean_generated_site }
      end
    end
  end
end
