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
    test_site.posts.select { |post| post.slug == 'another-post' }.first
  end

  it 'parses its YAML front matter' do
    subject.title.must_equal('My second post')
    subject.categories.sort.must_equal(['green'])
  end

  it 'finds its next post' do
    subject.next_post.slug.must_equal('yet-another-post')
  end

  it 'finds its previous post' do
    subject.previous_post.slug.must_equal('a-post')
  end

  it 'correctly sets its slug' do
    subject.slug.must_equal('another-post')
  end

  it 'correctly sets its date' do
    subject.year.must_equal('2015')
    subject.month.must_equal('02')
    subject.day.must_equal('01')
  end

  it 'returns the correct value when inspected' do
    subject.inspect.must_equal "#<Dimples::Post @slug=#{subject.slug} @output_path=#{subject.output_path}>"
  end

  describe 'when publishing' do
    before { subject.write }

    it 'creates the generated file' do
      compare_file_to_fixture(subject.output_path, 'posts/2015-02-01-another-post')
    end
  end
end
