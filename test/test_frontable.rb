# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Frontable do
  before do
    @site = Dimples::Site.new(test_configuration)
    @fixture_path = File.join(__dir__, 'fixtures', 'frontable')
  end

  describe 'when calling read_with_front_matter' do
    describe 'on a file containing front matter' do
      describe 'with only allowed keys' do
        before do
          @page = Dimples::Page.new(
            @site,
            File.join(@fixture_path, 'front_matter_allowed_keys.json')
          )
        end

        it 'sets the correct values' do
          @page.read_with_front_matter

          @page.layout.must_equal('default')
          @page.extension.must_equal('txt')
        end
      end

      describe 'with a mix of allowed and skipped keys' do
        before do
          @page = Dimples::Page.new(
            @site,
            File.join(@fixture_path, 'front_matter_mixed_keys.json')
          )
        end

        it 'sets the correct values and ignores the rest' do
          original_path = @page.path

          @page.read_with_front_matter

          @page.path.must_equal(original_path)
          @page.contents.must_equal('Hello.')
          @page.layout.must_equal('default')
          @page.extension.must_equal('json')
        end
      end
    end

    describe 'on a file without front matter' do
      before do
        @page = Dimples::Page.new(
          @site,
          File.join(@fixture_path, 'no_front_matter.json')
        )
      end

      it 'reads in the contents correctly' do
        @page.read_with_front_matter
        @page.contents.must_equal('Hello.')
      end
    end
  end
end
