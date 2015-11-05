$:.unshift(__dir__)

require 'helper'

describe "Template" do
  before { @site = test_site }
  subject { Dimples::Template.new(@site, File.join(@site.source_paths[:templates], 'default.erb')) }

  it "renders its contents" do
    expected_output = <<EXPECTED
<!DOCTYPE html>
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>My site</title>
</head>
<body>
Welcome
</body>
</html>
EXPECTED

    subject.render({}, 'Welcome').must_equal(expected_output.strip)
  end
end