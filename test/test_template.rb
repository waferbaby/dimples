$:.unshift(__dir__)

require 'helper'

describe "Template" do
  before { @site = test_site }
  subject { Dimples::Template.new(@site, File.join(@site.source_paths[:templates], 'default.erb')) }

  it "renders its contents" do
    expected_output = render_fixture('template.erb')
    subject.render({}, 'Welcome').must_equal(expected_output)
  end
end