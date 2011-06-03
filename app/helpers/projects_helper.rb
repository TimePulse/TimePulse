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


  def list_tree(projects, depth = 0, partial = "projects/project")
    String.new.tap do |str|
      [*projects].each do |project|
        Project.each_with_level(project.self_and_descendants) do |project, depth|
          str << (render :partial => partial, :locals => { :project => project, :depth => depth }) unless project.nil?
        end
      end
      str.html_safe
    end
  end


  def depth_indicator(depth)
    str = ''
    if depth > 0
      depth.times do
        str << image_tag("/images/icons/spacer.png", :class=> "inline", :size =>"10x12", :alt => "&nbsp;&nbsp;&nbsp;")
      end
      str << image_tag("/images/icons/indent_arrow.png", :class=>"inline", :size => "12x12", :alt => '->')
    end
    str.html_safe
  end


  def short_name_with_client(project)
    return unless project
    String.new.tap do |str|
      str << truncate(project.name, :length => 20, :omission => '...')
      str << "&nbsp;"
      str << "[#{project.client.abbreviation}]" unless project.client.nil?
      str.html_safe
    end
  end

  def clock_in_widget(project, style = nil)

    title = "Clock in on #{project.name}"
    content_tag(:form,  :action => clock_in_path(:id => project), :method => :post, :title => title, :class => "clock_in") do
      if defined?(style)  and style == :icon
        image_submit_tag('/images/icons/clock_in.png', :alt => title)
      else
        submit_tag(title)
      end
    end
    # render :inline => 'shared/clock_in_widget', :locals => {:style => :icon, :project => project}
  end

end
