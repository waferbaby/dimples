# frozen_string_literal: true

$LOAD_PATH.unshift(__dir__)

require 'helper'

describe Dimples::Frontable do
  let(:fixture_path) { File.join(__dir__, 'fixtures', 'frontable') }

  describe 'when calling read_with_front_matter' do
    describe 'on a file containing front matter' do
      describe 'with only allowed keys' do
        subject do
          Dimples::Page.new(
            test_site,
            File.join(fixture_path, 'front_matter_allowed_keys')
          )
        end

        it 'sets the correct values' do
          subject.read_with_front_matter

          subject.layout.must_equal('default')
          subject.extension.must_equal('txt')
        end
      end

      describe 'with a mix of allowed and skipped keys' do
        subject do
          Dimples::Page.new(
            test_site,
            File.join(fixture_path, 'front_matter_mixed_keys')
          )
        end

        let(:original_path) { subject.path }

        it 'sets the correct values and ignores the rest' do
          subject.read_with_front_matter

          subject.path.must_equal(original_path)
          subject.contents.must_equal('Hello.')
          subject.layout.must_equal('default')
          subject.extension.must_equal('json')
        end
      end
    end

    describe 'on a file without front matter' do
      subject do
        Dimples::Page.new(
          test_site,
          File.join(fixture_path, 'no_front_matter')
        )
      end

      it 'reads in the contents correctly' do
        subject.read_with_front_matter
        subject.contents.must_equal('Hello.')
      end
    end
  end
end
