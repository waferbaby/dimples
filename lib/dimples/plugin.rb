module Dimples
  class Plugin
    EVENTS = %i[
      post_write
      page_write
    ].freeze

    def self.inherited(subclass)
      (@subclasses ||= []) << subclass
    end

    def self.plugins(site)
      @plugins ||= {}.tap do |plugins|
        @subclasses.each do |subclass|
          plugin = subclass.new(site)

          plugin.supported_events.each do |event|
            (plugins[event] ||= []) << plugin
          end
        end
      end
    end

    def self.process(site, action, item, &block)
      plugins(site)[action]&.each { |plugin| plugin.process(action, item, &block) }
      yield
    end

    def initialize(site)
      @site = site
    end

    def process(action, item, &block)
    end

    def supported_events
      []
    end
  end
end