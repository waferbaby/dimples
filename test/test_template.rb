# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Template do
  before do
    @site = Dimples::Site.new(test_configuration)
    @site.scan_files

    @template = Dimples::Template.new(
      @site,
      File.join(@site.source_paths[:templates], 'post.erb')
    )
  end

  it 'parses its YAML front matter' do
    @template.layout.must_equal('default')
  end

  it 'returns the correct value when inspected' do
    @template.inspect.must_equal(
      "#<Dimples::Template @slug=#{@template.slug} @path=#{@template.path}>"
    )
  end
end
