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

    describe 'when paginating' do
      before do
        module Dimples
          class Site
            public :build_pagination
          end
        end
      end

      after do
        module Dimples
          class Site
            private :build_pagination
          end
        end
      end

      describe 'the first page' do
        before { @pagination = test_site.build_pagination(1, 3, 3, '/') }

        it 'has no previous page number' do
          @pagination[:previous_page].must_be_nil
        end

        it 'has no URL for the previous page' do
          @pagination[:previous_page_url].must_be_nil
        end

        it 'has a next page number' do
          @pagination[:next_page].must_equal(2)
        end

        it 'has a URL for the next page' do
          @pagination[:next_page_url].must_equal('/page2')
        end
      end

      describe 'the middle page' do
        before { @pagination = test_site.build_pagination(2, 3, 3, '/') }

        it 'has a previous page number' do
          @pagination[:previous_page].must_equal(1)
        end

        it 'has a numberless URL for the first page' do
          @pagination[:previous_page_url].must_equal('/')
        end

        it 'has a next page number' do
          @pagination[:next_page].must_equal(3)
        end

        it 'has a URL for the next page' do
          @pagination[:next_page_url].must_equal('/page3')
        end
      end

      describe 'the last page' do
        before { @pagination = test_site.build_pagination(3, 3, 3, '/') }

        it 'has a previous page number' do
          @pagination[:previous_page].must_equal(2)
        end

        it 'has a URL for the previous page' do
          @pagination[:previous_page_url].must_equal('/page2')
        end

        it 'has no next page number' do
          @pagination[:next_page].must_be_nil
        end

        it 'has no URL for the next page' do
          @pagination[:next_page_url].must_be_nil
        end
      end
    end
  end
end
