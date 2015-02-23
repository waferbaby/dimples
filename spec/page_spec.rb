require 'dimples'

describe 'A page', publishing: true do

  subject { @site.pages[0] }
    
  it 'should create a file when published' do
    subject.write(@site.output_paths[:site])
    expect(File).to exist(subject.output_file_path(@site.output_paths[:site]))
  end

  it 'should render using a template' do
    output = subject.render()
    expected = <<EXPECTED
<!DOCTYPE html>
<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>About</title>
</head>
<body>
<h2>About this site</h2>
<p>Hello! I'm an about page.</p>
</body>
</html>
EXPECTED

    expected.rstrip!

    expect(output).to eql(expected)
  end

end