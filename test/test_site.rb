# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'
require 'timecop'

describe Dimples::Site do
  before { @site = Dimples::Site.new(test_configuration) }

  it 'returns the correct value when inspected' do
    @site.inspect.must_equal(
      '#<Dimples::Site ' \
      "@source_paths=#{@site.source_paths} " \
      "@output_paths=#{@site.output_paths}>"
    )
  end

  describe 'when generating' do
    describe 'with default settings' do
      before do
        Timecop.freeze(Time.local(2017, 1, 1, 0, 0, 0))
        @site.generate
        Timecop.return
      end

      %w[templates pages posts].each do |file_type|
        it "finds all the #{file_type} files" do
          file_type_sym = file_type.to_sym

          glob_path = File.join(
            @site.source_paths[file_type_sym],
            '**',
            '*.*'
          )

          length = Dir.glob(glob_path).length
          @site.send(file_type_sym).length.must_equal(length)
        end
      end

      it 'prepares the archive data' do
        years = @site.posts.map(&:year).uniq.sort
        @site.archives[:year].keys.sort.must_equal(years)

        months = @site.posts.map do |post|
          "#{post.year}-#{post.month}"
        end.uniq.sort

        @site.archives[:month].keys.sort.must_equal(months)

        days = @site.posts.map do |post|
          "#{post.year}-#{post.month}-#{post.day}"
        end.uniq.sort

        @site.archives[:day].keys.sort.must_equal(days)
      end

      it 'prepares the output directory' do
        File.directory?(@site.output_paths[:site]).must_equal(true)
      end

      it 'creates all the posts' do
        @site.posts.each do |post|
          date = "#{post.year}-#{post.month}-#{post.day}-#{post.slug}"
          expected_output = fixtures["posts.#{date}"]

          File.exist?(post.output_path).must_equal(true)
          File.read(post.output_path).must_equal(expected_output)
        end
      end

      it 'creates all the posts feeds' do
        @site.feed_templates.each do |template|
          feed_type = template.split('.')[1]

          path = File.join(
            @site.output_paths[:site],
            "feed.#{feed_type}"
          )

          expected_output = fixtures["pages.feeds.#{feed_type}_posts"]

          File.exist?(path).must_equal(true)
          File.read(path).must_equal(expected_output)
        end
      end

      it 'creates all the main pages' do
        @site.pages.each do |page|
          filename = File.basename(page.output_path, '.html')
          directory = File.dirname(page.output_path).sub(
            @site.output_paths[:site],
            ''
          )[1..-1]

          expected_output = fixtures["pages.#{directory}.#{filename}"]

          File.exist?(page.output_path).must_equal(true)
          File.read(page.output_path).must_equal(expected_output)
        end
      end

      %w[year month day].each do |date_type|
        it "creates the #{date_type} archives" do
          @site.archives[date_type.to_sym].each_key do |date|
            path = File.join(
              @site.output_paths[:archives],
              date.split('-'),
              'index.html'
            )

            expected_output = fixtures["pages.archives.#{date}"]

            File.exist?(path).must_equal(true)
            File.read(path).must_equal(expected_output)
          end
        end
      end

      it 'creates all the category pages' do
        categories_path = @site.output_paths[:categories]

        @site.categories.each_key do |slug|
          path = File.join(categories_path, slug, 'index.html')
          expected_output = fixtures["pages.categories.#{slug}"]

          File.exist?(path).must_equal(true)
          File.read(path).must_equal(expected_output)
        end
      end

      it 'creates all the category feeds' do
        categories_path = @site.output_paths[:categories]

        @site.categories.each_key do |slug|
          @site.feed_templates.each do |template|
            feed_type = template.split('.')[1]

            path = File.join(categories_path, slug, "feed.#{feed_type}")
            expected_output = fixtures["pages.feeds.#{slug}_#{feed_type}_posts"]

            File.exist?(path).must_equal(true)
            File.read(path).must_equal(expected_output)
          end
        end
      end

      it 'copies all the asset files' do
        glob_path = File.join(@site.source_paths[:public], '**', '*')

        Dir.glob(glob_path).each do |asset_path|
          path = asset_path.sub(
            @site.source_paths[:public],
            @site.output_paths[:site]
          )

          File.exist?(path).must_equal(true)
        end
      end

      after { clean_generated_site(@site) }
    end

    describe 'with custom settings' do
      describe 'if the main feeds are disabled' do
        before do
          @site.config[:generation][:feeds] = false
          @site.generate
        end

        it 'creates none of the feeds' do
          @site.feed_templates.each do |template|
            path = File.join(
              @site.output_paths[:site],
              "feed.#{template.split('.')[1]}"
            )

            File.exist?(path).must_equal(false)
          end
        end

        after { clean_generated_site(@site) }
      end

      %w[year month day].each do |date_type|
        describe "if #{date_type} generation is disabled" do
          before do
            @site.config[:generation]["#{date_type}_archives".to_sym] = false
            @site.generate
          end

          it 'creates no archive files' do
            @site.archives[date_type.to_sym].each_key do |date|
              path = File.join(
                @site.output_paths[:archives],
                date.split('-'),
                'index.html'
              )

              File.exist?(path).must_equal(false)
            end
          end

          after { clean_generated_site(@site) }
        end
      end

      describe 'if category generation is disabled' do
        before do
          @site.config[:generation][:categories] = false
          @site.generate
        end

        it 'creates none of the category files' do
          @site.categories.each_key do |slug|
            categories_path = @site.output_paths[:categories]
            path = File.join(categories_path, slug, 'index.html')

            File.exist?(path).must_equal(false)
          end
        end

        after { clean_generated_site(@site) }
      end

      describe 'if category feed generation is disabled' do
        before do
          @site.config[:generation][:category_feeds] = false
          @site.generate
        end

        it 'creates no category feeds' do
          @site.categories.each_key do |slug|
            categories_path = @site.output_paths[:categories]

            @site.feed_templates.each do |template|
              path = File.join(
                categories_path,
                slug,
                "feed.#{template.split('.')[1]}"
              )

              File.exist?(path).must_equal(false)
            end
          end
        end

        after { clean_generated_site(@site) }
      end

      describe 'with custom category names' do
        before do
          @site.config[:category_names][:green] = 'G R E E N'
          @site.generate
        end

        it 'uses the name correctly' do
          categories_path = @site.output_paths[:categories]
          path = File.join(categories_path, 'green', 'index.html')
          expected_output = fixtures['pages.categories.custom_green']

          File.exist?(path).must_equal(true)
          File.read(path).must_equal(expected_output)
        end

        after { clean_generated_site(@site) }
      end
    end
  end
end
