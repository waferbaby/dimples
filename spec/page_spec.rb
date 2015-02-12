require 'salt'

describe 'A page' do

  let!(:site) do
    site = Salt::Site.new()
    site.templates['test'] = Salt::Template.new(site, File.join(File.dirname(__dir__), 'spec', 'template.erb'))

    site
  end

  subject { Salt::Page.new(site) }
    
  it 'should create a file when published' do
    subject.filename = 'salt_test_' + Time.new.strftime('%s')
    subject.write('/tmp/')

    file_path = subject.output_file_path('/tmp/')

    result = File.exist?(file_path)
    File.delete(file_path)

    expect(result).to be_truthy
  end

  it 'should render using a template' do
    subject.contents = "Wow, butts!"
    subject.layout = 'test'

    output = subject.render(subject.contents())

    expect(output).to match("<strong>Wow, butts!</strong>")
  end

end