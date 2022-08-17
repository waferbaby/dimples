# frozen_string_literal: true

module Dimples
  class Site
    def self.generate(output_path)
      new(output_path).generate
    end

    def initialize(output_path)
      @paths = {
        source: File.expand_path(Dir.pwd),
        destination: File.expand_path(output_path)
      }

      %w[pages posts static templates].each do |type|
        @paths[type.to_sym] = File.join(@paths[:source], type)
      end

      scan_files
      prepare_archives
    end

    def scan_files
      @posts = read_files(@paths[:posts]).map do |path|
        Dimples::Post.new(path)
      end

      @pages = read_files(@paths[:pages]).map do |path|
        Dimples::Page.new(path)
      end

      @templates = {}.tap do |templates|
        read_files(@paths[:templates]).each do |path|
          key = File.basename(path, '.erb')
          templates[key] = Dimples::Template.new(path)
        end
      end
    end

    def generate
    end

    private

    def read_files(path)
      Dir[File.join(path, '**', '*.*')].sort
    end

    def prepare_archives
      @archives = {}

      @posts.each do |post|
        year = post.date.year
        month = post.date.strftime('%m')

        @archives[year] ||= {}
        @archives[year][month] ||= []
        @archives[year][month] << post
      end
    end
  end
end
