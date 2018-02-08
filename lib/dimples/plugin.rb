module Dimples
  class Plugin
    def self.inherited(subclass)
      (@subclasses ||= []) << subclass
    end

    def self.plugins(site)
      @plugins ||= @subclasses.map { |subclass| subclass.new(site) }
    end

    def self.process(site, event, item, &block)
      plugins(site).each do |plugin|
        plugin.process(event, item, &block) if plugin.supports_event?(event)
      end

      yield if block_given?
    end

    def initialize(site)
      @site = site
    end

    def process(event, item, &block)
    end

    def supported_events
      []
    end

    def supports_event?(event)
      supported_events.include?(event)
    end
  end
end