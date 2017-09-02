# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Post do
  before do
    @site = Dimples::Site.new(test_configuration)
    @site.scan_files
    @post = @site.posts.select { |post| post.slug == 'another-post' }.first
  end

  it 'parses its YAML front matter' do
    @post.title.must_equal('My second post')
    @post.categories.sort.must_equal(['green'])
  end

  it 'finds its next post' do
    @post.next_post.slug.must_equal('yet-another-post')
  end

  it 'finds its previous post' do
    @post.previous_post.slug.must_equal('a-post')
  end

  it 'correctly sets its slug' do
    @post.slug.must_equal('another-post')
  end

  it 'correctly sets its date' do
    @post.year.must_equal('2015')
    @post.month.must_equal('02')
    @post.day.must_equal('01')
  end

  it 'returns the correct value when inspected' do
    @post.inspect.must_equal(
      "#<Dimples::Post @slug=#{@post.slug} " \
      "@output_path=#{@post.output_path}>"
    )
  end

  describe 'when publishing' do
    before { @post.write }

    it 'creates the generated file' do
      expected_output = fixtures['posts.2015-02-01-another-post']

      File.exist?(@post.output_path)
      File.read(@post.output_path).must_equal(expected_output)
    end
  end
end
