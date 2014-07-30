# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def logged_in?
    !current_user.nil?
  end

  def admin?
    logged_in? and current_user.admin?
  end

  def body_class
    klasses = params[:controller].split("/")
    klasses << params[:action]
    klasses << 'with_admin' if admin?
    klasses << @body_classes if @body_classes
    klasses
  rescue
    ''
  end

  def add_body_class(klass)
    if @body_classes
      @body_classes << klass
    else
      @body_classes = [klass]
    end
  end


  def clocked_in_project?(project)
    return true if current_work_unit && current_work_unit.project == project
  end

  def labeled_datepicker_field(form, field_name, options = {})
    options.reverse_merge!(:class => :date_entry) unless options[:class]
    fieldval =  form.object.send(field_name)
    value = fieldval ? fieldval.strftime('%b %d, %Y'): nil
    form.labeled_input(field_name, options.merge!(
      :class => options[:class],
      :value => value
    )).html_safe
  end

  def labeled_datetimepicker_field(form, field_name, options = {})
    labeled_datepicker_field(form, field_name, options.merge!( :class => :datetime_entry ))
  end

  def work_unit_stop_time(work_unit)
    if (work_unit.stop_time.present?)
      work_unit.stop_time.try(:to_s, :time)
    else
     link_to("Fix",
       fix_work_unit_path(:id => work_unit.id),
       :id => "fix_" + dom_id(work_unit),
       :class => 'fix_work_unit_button'
     )
    end
  end

  def link_to_if_authorized(authorized_test, name, options = nil, html_options = nil)
    options ||= {}
    html_options ||= {}
    url = options
    if authorized_test
      return link_to(name, options, html_options)
    else
      if block_given?
        yield
      end
      return ""
    end
  end

  def link_to_if_admin_authorized(name, options = nil, html_options = nil)
    authorized_test = current_user and current_user.admin?
    link_to_if_authorized(authorized_test, name, options, html_options)
  end

  def link_to_if_owner_authorized(owner, name, options = nil, html_options = nil)
    authorized_test = current_user and (current_user.admin? or current_user == owner)
    link_to_if_authorized(authorized_test, name, options, html_options)
  end

  def slide_toggle_tag(tag, title, target, options = {})
    options["data-target"] = target
    options[:class] = "toggler"
    content_tag(tag, title, options)
  end

  def block_title(title, cssid)
    if (cssid.present?)
      slide_toggle_tag(:h2, title.upcase, "#{cssid.to_s} .block_content")
    else
      content_tag(:h2, title.upcase, :class => 'block_title')
    end
  end

  def project_options
    sorted_projects = Project.all.sort_by(&:lft)

    sorted_projects.collect do |p|
      attributes = {}
      attributes['class'] = "indention_level_#{p.level}"
      if p.level > 1
        attributes['data-iconurl'] = '/assets/icons/indent_arrow.png'
      end
      [p.name, p.id, attributes]
    end
  end
end
