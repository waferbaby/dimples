# frozen_string_literal: true

module Dimples
  # A Ruby class that can receive events from Dimples as a site is processed.
  class Plugin
    EVENTS = %i[
      before_site_generation
      after_site_generation
      before_post_write
      before_page_write
      after_post_write
      after_page_write
    ].freeze

    def self.inherited(subclass)
      (@subclasses ||= []) << subclass
    end

    def self.plugins(site)
      @plugins ||= @subclasses&.map { |subclass| subclass.new(site) }
    end

    def self.send_event(site, event, item = nil)
      plugins(site)&.each do |plugin|
        plugin.process(event, item) if plugin.supports_event?(event)
      end
    end

    def initialize(site)
      @site = site
    end

    def process(event, item, &block); end

    def supported_events
      []
    end

    def supports_event?(event)
      supported_events.include?(event)
    end
  end
end
