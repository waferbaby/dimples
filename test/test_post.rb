# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Post' do
  before do
    test_site.scan_templates
    test_site.scan_pages
    test_site.scan_posts
  end

  subject do
    filename = '2015-01-01-a-post.markdown'
    file_path = File.join(test_site.source_paths[:posts], filename)
    Dimples::Post.new(test_site, file_path)
  end

  it 'parses its YAML front matter' do
    subject.title.must_equal('My first post')
    subject.categories.sort.must_equal(%w[green red])
  end

  it 'correctly sets its slug' do
    subject.slug.must_equal('a-post')
  end

  it 'correctly sets its date' do
    subject.year.must_equal('2015')
    subject.month.must_equal('01')
    subject.day.must_equal('01')
  end

  describe 'when publishing' do
    let(:file_path) { subject.output_path(test_site.output_paths[:site]) }
    before { subject.write(file_path) }

    it 'creates the generated file' do
      File.exist?(file_path).must_equal(true)
      compare_file_to_fixture(file_path, 'posts/2015-01-01-a-post')
    end
  end
end
