ActionView::Template.register_template_handler("ic",
  Proc.new do |template|
    <<-RUBY
    begin
      _old_formats = lookup_context.formats
      lookup_context.formats = _old_formats + [:html]
      return (#{template.source}).to_json
    rescue Object => ex
      return { :error => ex.message, :exception => ex.class.name, :trace => caller[0..10] }.to_json
    ensure
      lookup_context.formats = _old_formats
    end
    RUBY
  end )
