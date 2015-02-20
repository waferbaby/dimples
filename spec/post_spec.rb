require 'dimples'

describe 'A post' do

  subject { @site.posts[0] }
    
  it 'should create a file when published' do
    subject.write(@site.output_paths[:posts])
    result = File.exist?(subject.output_file_path(@site.output_paths[:posts]))

    expect(result).to be_truthy
  end

  it 'should render using a template' do
    output = subject.render()
    expected = <<EXPECTED
<!DOCTYPE html>
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>My first post</title>
</head>
<body>
<h2>My first post</h2>
<h3>Hello</h3>

<p>Welcome to my <strong>first post</strong>.</p>
</body>
</html>
EXPECTED

    expected.rstrip!
    
    expect(output).to match(expected)
  end

end