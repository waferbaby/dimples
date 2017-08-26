# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Template' do
  before do
    test_site.scan_templates
    test_site.scan_pages
    test_site.scan_posts
  end

  subject do
    file_path = File.join(test_site.source_paths[:templates], 'post.erb')
    Dimples::Template.new(test_site, file_path)
  end

  it 'parses its YAML front matter' do
    subject.layout.must_equal('default')
  end
end
