# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Template' do
  subject do
    path = File.join(test_site.source_paths[:templates], 'default.erb')
    Dimples::Template.new(test_site, path)
  end

  it 'renders its contents' do
    expected_output = render_template('template')
    subject.render({}, 'Welcome').must_equal(expected_output)
  end
end
