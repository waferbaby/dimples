# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Template' do
  before { @site = test_site }
  subject do
    path = File.join(@site.source_paths[:templates], 'default.erb')
    Dimples::Template.new(@site, path)
  end

  it 'renders its contents' do
    expected_output = render_fixture('template.erb')
    subject.render({}, 'Welcome').must_equal(expected_output)
  end
end
