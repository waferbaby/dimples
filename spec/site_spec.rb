require 'dimples'

describe 'A site' do

  subject { @site }

  it "should find its templates for publishing" do
    @site.scan_templates
    expect(@site.templates['default']).to be_a_kind_of Dimples::Template
  end

  it "should find its posts for publishing" do
    @site.scan_posts
    expect(@site.posts[0]).to be_a_kind_of Dimples::Post
  end

  it "should find its pages for publishing" do
    @site.scan_pages
    expect(@site.pages[0]).to be_a_kind_of Dimples::Page
  end
end