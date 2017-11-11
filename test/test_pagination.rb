# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Pagination do
  before do
    @site = Dimples::Site.new(test_configuration)
    @site.config[:pagination][:per_page] = 2
    @site.scan_files

    @paginated_path = File.join(@site.output_paths[:site], 'archives')
  end

  include Dimples::Pagination

  describe 'when paginating' do
    describe 'without options' do
      before do
        paginate(@site, @site.posts, @paginated_path, 'paginated')
      end

      it 'creates the main index file' do
        path = File.join(@paginated_path, 'index.html')
        expected_output = fixtures['pages.pagination.index']

        File.exist?(path).must_equal(true)
        File.read(path).must_equal(expected_output)
      end

      it 'creates paged directories with index files' do
        path = File.join(@paginated_path, 'page2', 'index.html')
        expected_output = fixtures['pages.pagination.page_2']

        File.exist?(path).must_equal(true)
        File.read(path).must_equal(expected_output)
      end
    end

    describe 'with options' do
      before do
        options = {
          title: 'All My Posts',
          extension: 'htm',
          per_page: 1
        }

        paginate(
          @site,
          @site.posts,
          @paginated_path,
          'paginated',
          options
        )
      end

      it 'creates the main custom index file' do
        path = File.join(@paginated_path, 'index.htm')
        expected_output = fixtures['pages.pagination.custom_index']

        File.exist?(path).must_equal(true)
        File.read(path).must_equal(expected_output)
      end

      it 'creates paged directories with index files' do
        (2..3).each do |index|
          path = File.join(@paginated_path, "page#{index}", 'index.htm')
          expected_output = fixtures["pages.pagination.custom_page_#{index}"]

          File.exist?(path).must_equal(true)
          File.read(path).must_equal(expected_output)
        end
      end
    end
  end

  describe 'Pager' do
    describe 'with the default options' do
      before do
        @pager = Dimples::Pagination::Pager.new('/archives/', @site.posts, 1)
      end

      it 'has the correct first page url' do
        @pager.first_page_url.must_equal('/archives/')
      end

      it 'has the correct last page url' do
        @pager.last_page_url.must_equal('/archives/page3')
      end

      describe 'starting from the first page' do
        it 'is on the correct page' do
          @pager.current_page.must_equal(1)
        end

        it 'has no previous page' do
          @pager.previous_page.must_be_nil
        end

        it 'has no previous page url' do
          @pager.previous_page_url.must_be_nil
        end

        it 'has the correct next page' do
          @pager.next_page.must_equal(2)
        end

        it 'has the correct next page url' do
          @pager.next_page_url.must_equal('/archives/page2')
        end
      end

      describe 'stepping forwards one page' do
        before do
          @pager.step_to(2)
        end

        it 'is on the correct page' do
          @pager.current_page.must_equal(2)
        end

        it 'has the correct previous page' do
          @pager.previous_page.must_equal(1)
        end

        it 'has the correct previous page url' do
          @pager.previous_page_url.must_equal('/archives/')
        end

        it 'has the correct next page' do
          @pager.next_page.must_equal(3)
        end

        it 'has the correct next page url' do
          @pager.next_page_url.must_equal('/archives/page3')
        end
      end

      describe 'stepping to the last page' do
        before do
          @pager.step_to(@pager.page_count)
        end

        it 'is on the correct page' do
          @pager.current_page.must_equal(@pager.page_count)
        end

        it 'has the correct previous page' do
          @pager.previous_page.must_equal(@pager.page_count - 1)
        end

        it 'has the correct previous page url' do
          url = "/archives/page#{@pager.page_count - 1}"
          @pager.previous_page_url.must_equal(url)
        end

        it 'has no next page' do
          @pager.next_page.must_be_nil
        end

        it 'has no next page url' do
          @pager.next_page_url.must_be_nil
        end
      end
    end

    describe 'with custom options' do
      before do
        @pager = Dimples::Pagination::Pager.new(
          '/archives/',
          @site.posts,
          1,
          'page_prefix': '?page='
        )
      end

      it 'has the correct first page url' do
        @pager.first_page_url.must_equal('/archives/')
      end

      it 'has the correct last page url' do
        @pager.last_page_url.must_equal('/archives/?page=3')
      end

      describe 'starting from the first page' do
        it 'has no previous page url' do
          @pager.previous_page_url.must_be_nil
        end

        it 'has the correct next page url' do
          @pager.next_page_url.must_equal('/archives/?page=2')
        end
      end

      describe 'stepping forwards one page' do
        before do
          @pager.step_to(2)
        end

        it 'has the correct previous page url' do
          @pager.previous_page_url.must_equal('/archives/')
        end

        it 'has the correct next page url' do
          @pager.next_page_url.must_equal('/archives/?page=3')
        end
      end

      describe 'stepping to the last page' do
        before do
          @pager.step_to(@pager.page_count)
        end

        it 'has the correct previous page url' do
          url = "/archives/?page=#{@pager.page_count - 1}"
          @pager.previous_page_url.must_equal(url)
        end

        it 'has no next page url' do
          @pager.next_page_url.must_be_nil
        end
      end
    end
  end
end
