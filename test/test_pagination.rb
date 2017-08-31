# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Pagination do
  before do
    test_site.config['pagination']['per_page'] = 2

    test_site.scan_templates
    test_site.scan_pages
    test_site.scan_posts
  end

  include Dimples::Pagination

  let(:paginated_path) { File.join(test_site.output_paths[:site], 'archives') }

  describe 'when paginating' do
    describe 'without options' do
      before do
        paginate(test_site, test_site.posts, paginated_path, 'paginated')
      end

      it 'creates the main index file' do
        file_path = File.join(paginated_path, 'index.html')
        File.exist?(file_path).must_equal(true)
        compare_file_to_fixture(file_path, 'pages/pagination/index')
      end

      it 'creates paged directories with index files' do
        file_path = File.join(paginated_path, 'page2', 'index.html')
        File.exist?(file_path).must_equal(true)
        compare_file_to_fixture(file_path, 'pages/pagination/page_2')
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
          test_site,
          test_site.posts,
          paginated_path,
          'paginated',
          options
        )
      end

      it 'creates the main custom index file' do
        file_path = File.join(paginated_path, 'index.htm')
        File.exist?(file_path).must_equal(true)
        compare_file_to_fixture(file_path, 'pages/pagination/custom_index')
      end

      it 'creates paged directories with index files' do
        (2..3).each do |index|
          file_path = File.join(paginated_path, "page#{index}", 'index.htm')
          File.exist?(file_path).must_equal(true)
          fixture = "pages/pagination/custom_page_#{index}"
          compare_file_to_fixture(file_path, fixture)
        end
      end
    end
  end

  describe 'Pager' do
    describe 'with the default options' do
      subject do
        Dimples::Pagination::Pager.new('/archives/', test_site.posts, 1)
      end

      describe 'starting from the first page' do
        it 'is on the correct page' do
          subject.current_page.must_equal(1)
        end

        it 'has no previous page' do
          subject.previous_page.must_be_nil
        end

        it 'has no previous page url' do
          subject.previous_page_url.must_be_nil
        end

        it 'has the correct next page' do
          subject.next_page.must_equal(2)
        end

        it 'has the correct next page url' do
          subject.next_page_url.must_equal('/archives/page2')
        end
      end

      describe 'stepping forwards one page' do
        before do
          subject.step_to(2)
        end

        it 'is on the correct page' do
          subject.current_page.must_equal(2)
        end

        it 'has the correct previous page' do
          subject.previous_page.must_equal(1)
        end

        it 'has the correct previous page url' do
          subject.previous_page_url.must_equal('/archives/')
        end

        it 'has the correct next page' do
          subject.next_page.must_equal(3)
        end

        it 'has the correct next page url' do
          subject.next_page_url.must_equal('/archives/page3')
        end
      end

      describe 'stepping to the last page' do
        before do
          subject.step_to(subject.page_count)
        end

        it 'is on the correct page' do
          subject.current_page.must_equal(subject.page_count)
        end

        it 'has the correct previous page' do
          subject.previous_page.must_equal(subject.page_count - 1)
        end

        it 'has the correct previous page url' do
          url = "/archives/page#{subject.page_count - 1}"
          subject.previous_page_url.must_equal(url)
        end

        it 'has no next page' do
          subject.next_page.must_be_nil
        end

        it 'has no next page url' do
          subject.next_page_url.must_be_nil
        end
      end
    end

    describe 'with custom options' do
      subject do
        options = {
          'page_prefix': '?page='
        }

        Dimples::Pagination::Pager.new(
          '/archives/',
          test_site.posts,
          1,
          options
        )
      end

      describe 'starting from the first page' do
        it 'has no previous page url' do
          subject.previous_page_url.must_be_nil
        end

        it 'has the correct next page url' do
          subject.next_page_url.must_equal('/archives/?page=2')
        end
      end

      describe 'stepping forwards one page' do
        before do
          subject.step_to(2)
        end

        it 'has the correct previous page url' do
          subject.previous_page_url.must_equal('/archives/')
        end

        it 'has the correct next page url' do
          subject.next_page_url.must_equal('/archives/?page=3')
        end
      end

      describe 'stepping to the last page' do
        before do
          subject.step_to(subject.page_count)
        end

        it 'has the correct previous page url' do
          url = "/archives/?page=#{subject.page_count - 1}"
          subject.previous_page_url.must_equal(url)
        end

        it 'has no next page url' do
          subject.next_page_url.must_be_nil
        end
      end
    end
  end
end
