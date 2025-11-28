# frozen_string_literal: true

require 'fileutils'
require 'tmpdir'

describe Dimples::Site do
  subject(:site) { described_class.new(config: config) }

  let(:config) do
    {
      source: File.join(File.dirname(__dir__), 'fixtures'),
      build: File.join(Dir.tmpdir, "dimples-test-site-#{Time.now.to_i}")
    }
  end

  describe '#posts' do
    it 'builds a list of post objects' do
      expect(site.posts.count).to be(2)
    end
  end

  describe '#pages' do
    it 'builds a list of page objects' do
      expect(site.pages.count).to be(1)
    end
  end

  describe '#layouts' do
    it 'builds a list of layout objects' do
    end
  end

  describe '#categories' do
    it 'builds a list of posts grouped by category' do
      expect(site.categories.keys).to eql(%w[meta test personal])
    end
  end

  describe '#prepare_output_directory' do
    before { FileUtils.rm_rf(site.config.build_paths[:root]) }

    context 'when the target directory does not exist' do
      it 'creates the directory' do
        site.send(:prepare_output_directory)
        expect(Dir.exist?(site.config.build_paths[:root])).to be(true)
      end
    end

    context 'when the target directory already exists' do
      before { Dir.mkdir(site.config.build_paths[:root]) }

      it 'raises an error' do
        expect { site.send(:prepare_output_directory) }.to raise_error(RuntimeError)
      end
    end
  end
end
