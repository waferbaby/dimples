module Dimples
  module Renderable
    def render(contents, context = {})
      context[:site] ||= @site
      context.merge!(type => Hashie::Mash.new(@metadata))

      output = rendering_engine.render(Object.new, context) { contents }

      return output unless (template = @site.templates[@metadata[:layout]])
      template.render(output, context)
    end

    def rendering_engine
      @rendering_engine ||= begin
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