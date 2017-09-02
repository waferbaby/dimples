# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Page do
  before do
    @site = Dimples::Site.new(test_configuration)
    @site.scan_files
  end

  describe 'with a file path' do
    before do
      @page = Dimples::Page.new(
        @site,
        File.join(@site.source_paths[:pages], 'about', 'index.markdown')
      )
    end

    it 'parses its YAML front matter' do
      @page.title.must_equal('About')
      @page.layout.must_equal('default')
    end

    it 'returns the correct value when inspected' do
      @page.inspect.must_equal(
        "#<Dimples::Page @output_path=#{@page.output_path}>"
      )
    end

    describe 'when publishing' do
      before { @page.write }

      it 'creates the generated file' do
        expected_output = fixtures['pages.about.index']

        File.exist?(@page.output_path).must_equal(true)
        File.read(@page.output_path).must_equal(expected_output)
      end
    end
  end

  describe 'without a file path' do
    before do
      @page = Dimples::Page.new(@site)
    end

    it 'has no YAML front matter' do
      @page.title.must_be_nil
      @page.layout.must_be_nil
    end

    describe 'when publishing' do
      describe 'with no set contents' do
        before { @page.write }

        it 'creates an empty file' do
          File.exist?(@page.output_path).must_equal(true)
          File.read(@page.output_path).must_equal('')
        end
      end

      describe 'with customised contents' do
        before do
          @page.contents = 'Plain text file'
          @page.write
        end

        it 'creates a basic file without a template' do
          File.exist?(@page.output_path).must_equal(true)
          File.read(@page.output_path).must_equal('Plain text file')
        end
      end
    end
  end
end
