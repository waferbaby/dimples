module Dimples
  module Renderable
    def render(context)
      context[:site] ||= @site
      context[:page] ||= Hashie::Mash.new(@metadata)

      output = rendering_engine.render(Object.new, context) {
        context[:page]&.contents
      }

      if (template = @site.templates[@metadata[:layout]])
        context[:page].contents ||= output
        output = template.render(context)
      end

      output
    end

    private

    def rendering_engine
      @engine ||= begin
        callback = proc { @contents }

        if @path
          extension = File.extname(@path)
          options = @site.config.rendering[extension.to_sym] || {}

          Tilt.new(@path, options, &callback)
        else
          Tilt::StringTemplate.new(&callback)
        end
      end
    end
  end
end

#     def self.render_scope
#       @render_scope ||= Object.new.tap do |scope|
#         method_name = :render_template
#         scope.class.send(:define_method, method_name) do |site, template, locals = {}|
#           site.templates[template]&.render(context: locals)
#         end
#       end
#     end