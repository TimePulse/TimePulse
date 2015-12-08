module ProjectsHelper

  def parent_project_selector(form)
    form.select(:parent_id, project_options, { :include_blank => "" }, { :class => "project_selector"})
  end

  def  client_selector(form = nil)
    if form
      form.select(:client_id, client_selector_array, { :include_blank => "" })
    else
      if @client
        select_tag( :client_id, options_for_select(client_selector_array, @client.id), { :include_blank => "" })
      else
        select_tag( :client_id, options_for_select(client_selector_array), { :include_blank => "" })
      end
    end
  end

  def client_selector_array
    @client_array ||= Client.all.to_a.collect{ |c| [c.name, c.id] }
  end

  def project_name_with_client(project, short=false)
    return unless project
    String.new.tap do |str|
      str << "[#{project.client.abbreviation.try(:upcase)}] " unless project.client.nil?
      str << (short ? truncate(project.name, :length => 20, :omission => '...') : project.name)
    end.html_safe
  end

  def short_name_with_client(project)
    project_name_with_client(project, true)
  end

  def switch_to_project_link(project, link_name = nil, prefix = "")
     link_to(link_name.nil? ? project.name : link_name,
       set_current_project_path(:id => project.id),
       :method => :post,
       :id => prefix + "switch_to_" + dom_id(project)
     )
   end

  def clock_in_widget(project, style = nil, options = {})
    title = "Clock in on #{short_name_with_client(project)}"
    css_class = "clock_in_on_" + dom_id(project)
    if style == :icon
      link_to(image_tag('icons/clock_in.png', :alt => title), clock_in_path(:id => project),
              options.merge(:method => :post, :title => title, :class => css_class))
    else
      link_to(title, clock_in_path(:id => project),
              options.merge(:method => :post, :title => title, :class => css_class))
    end.html_safe
  end

  def expand_widget(project)
    cssid = "expand_" + dom_id(project)
    content_tag(:span, :class => "expand-widget", :id => cssid, :"data-target" => "##{dom_id(project)} > ul") do
      images = image_tag('icons/expand.png', :alt => "Expand", :class => "expand")
      images = images + image_tag('icons/collapse.png', :alt => "Collapse", :class => "collapse")
      images
    end
  end

  def project_form_options
    case action_name
    when "new", "create"
      {url: projects_path, method: :post}
    when "edit", "update"
      {url: project_path(@project_form.project), method: :put}
    end
  end

end
