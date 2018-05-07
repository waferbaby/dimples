# frozen_string_literal: true

module Dimples
  # A Ruby class that can receive events from Dimples as a site is processed.
  class Plugin
    EVENTS = %i[
      before_file_scanning
      after_file_scanning
      before_publishing
      after_publishing
      before_post_write
      before_page_write
      after_post_write
      after_page_write
    ].freeze

    class << self
      attr_reader :subclasses
    end

    def self.inherited(subclass)
      (@subclasses ||= []) << subclass
    end

    def initialize(site)
      @site = site
    end

    def process(event, item); end

    def supported_events
      []
    end

    def supports_event?(event)
      supported_events.include?(event)
    end
  end
end
