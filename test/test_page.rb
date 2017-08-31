# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Page do
  before do
    test_site.scan_templates
    test_site.scan_pages
    test_site.scan_posts
  end

  describe 'with a file path' do
    subject do
      file_path = File.join(
        test_site.source_paths[:pages],
        'about',
        'index.markdown'
      )

      Dimples::Page.new(test_site, file_path)
    end

    it 'parses its YAML front matter' do
      subject.title.must_equal('About')
      subject.layout.must_equal('default')
    end

    it 'returns the correct value when inspected' do
      subject.inspect.must_equal(
        "#<Dimples::Page @output_path=#{subject.output_path}>"
      )
    end

    describe 'when publishing' do
      before { subject.write }

      it 'creates the generated file' do
        File.exist?(subject.output_path).must_equal(true)
        fixture = 'pages/general/about/index'
        compare_file_to_fixture(subject.output_path, fixture)
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
      describe 'with no set contents' do
        before { subject.write }

        it 'creates an empty file' do
          File.exist?(subject.output_path).must_equal(true)
          File.read(subject.output_path).must_equal('')
        end
      end

      describe 'with customised contents' do
        before do
          subject.contents = 'Plain text file'
          subject.write
        end

        it 'creates a basic file without a template' do
          File.exist?(subject.output_path).must_equal(true)
          File.read(subject.output_path).must_equal('Plain text file')
        end
      end
    end
  end
end
