# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Pagination' do
  before do
    test_site.config['pagination']['per_page'] = 2
    test_site.scan_files
  end

  include Dimples::Pagination

  let(:paginated_path) { File.join(test_site.output_paths[:site], 'archives') }

  describe 'when paginating' do
    describe 'without options' do
      before do
        paginate(test_site, test_site.posts, paginated_path, 'paginated')
      end

      it 'creates the main index file' do
        path = File.join(paginated_path, 'index.html')
        File.exist?(path).must_equal(true)

        match_expected_output('pages/paginated_index', path)
      end

      it 'creates paged directories with index files' do
        path = File.join(paginated_path, "page2", 'index.html')
        File.exist?(path).must_equal(true)

        match_expected_output('pages/paginated_page_2', path)
      end
    end

    describe 'with options' do
      before do
        options = {
          title: 'All My Posts',
          extension: 'htm',
          per_page: 1
        }

        paginate(test_site, test_site.posts, paginated_path, 'paginated', options)
      end

      it 'creates the main custom index file' do
        path = File.join(paginated_path, 'index.htm')
        File.exist?(path).must_equal(true)

        match_expected_output('pages/custom_paginated_index', path)
      end

      it 'creates paged directories with index files' do
        (2..3).each do |index|
          path = File.join(paginated_path, "page#{index}", 'index.htm')
          File.exist?(path).must_equal(true)

          match_expected_output("pages/custom_paginated_page_#{index}", path)
        end
      end
    end
  end

  describe 'Pager' do
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
end
