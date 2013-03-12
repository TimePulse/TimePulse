module ProjectsHelper
  def project_parent_selector(form)
    form.select(:parent_id,
    Project.find(:all).collect  {|p| [p.name, p.id]}, { :include_blank => "" }
    )
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
    @client_array ||= Client.find(:all).collect{ |c| [c.name, c.id] }
  end

  def project_name_with_client(project, short=false)
    return unless project
    String.new.tap do |str|
      str << "[#{project.client.abbreviation.try(:upcase)}]&nbsp;" unless project.client.nil?
      str << (short ? truncate(project.name, :length => 20, :omission => '...') : project.name)
    end.html_safe
  end

  def short_name_with_client(project)
    project_name_with_client(project, true)
  end

  def switch_to_project_link(project)
     link_to(project.name,
       set_current_project_path(:id => project.id),
       :method => :post,
       :id => "switch_to_" + dom_id(project)
     )
   end

  def clock_in_widget(project, style = nil)
    title = "Clock in on #{short_name_with_client(project)}"
    cssid = "clock_in_on_" + dom_id(project)
    if style == :icon
      link_to(image_tag('icons/clock_in.png', :alt => title), clock_in_path(:id => project), :method => :post, :title => title, :id => cssid)
    else
      link_to(title, clock_in_path(:id => project), :method => :post, :title => title, :id => cssid)
    end.html_safe
  end

end
