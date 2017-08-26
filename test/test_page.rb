# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe 'Page' do
  before do
    test_site.scan_templates
    test_site.scan_pages
    test_site.scan_posts
  end

  describe 'with a file path' do
    subject do
      file_path = File.join(test_site.source_paths[:pages], 'about', 'index.markdown')
      Dimples::Page.new(test_site, file_path)
    end

    it 'parses its YAML front matter' do
      subject.title.must_equal('About')
      subject.layout.must_equal('default')
    end

    describe 'when publishing' do
      let(:file_path) { subject.output_path(test_site.output_paths[:site]) }
      before { subject.write(file_path) }

      it 'creates the generated file' do
        File.exist?(file_path).must_equal(true)
        compare_file_to_fixture(file_path, 'pages/general/about/index')
      end
    end
  end

  describe 'without a file path' do
    subject do
      Dimples::Page.new(test_site)
    end

    it 'has no YAML front matter' do
      subject.title.must_be_nil
      subject.layout.must_be_nil
    end

    describe 'when publishing' do
      let(:file_path) { subject.output_path(test_site.output_paths[:site]) }

      describe 'with no set contents' do
        before { subject.write(file_path) }

        it 'creates an empty file' do
          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal("")
        end
      end

      describe 'with customised contents' do
        before do
          subject.contents = 'Plain text file'
          subject.write(file_path)
        end

        it 'creates a basic file without a template' do
          File.exist?(file_path).must_equal(true)
          File.read(file_path).must_equal('Plain text file')
        end
      end
    end
  end
end
