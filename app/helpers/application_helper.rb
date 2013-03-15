# Methods added to this helper will be available to all templates in the application.
require 'authenticated_system'
module ApplicationHelper
  include AuthenticatedSystem

  def logged_in?
    !current_user.nil?
  end

  def admin?
    logged_in? and current_user.admin?
  end

  def clocked_in_project?(project)
    return true if current_work_unit && current_work_unit.project == project
  end

  def labeled_datepicker_field(form, field_name, options = {})
    options.reverse_merge!(:class => :date_entry) unless options[:class]
    fieldval =  form.object.send(field_name)
    value = fieldval ? fieldval.to_s(:long) : nil
    form.labeled_input(field_name, options.merge!(
      :class => options[:class],
      :value => value
    )).html_safe
  end

  def labeled_datetimepicker_field(form, field_name, options = {})
    labeled_datepicker_field(form, field_name, options.merge!( :class => :datetime_entry ))
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
      content_tag(:h2, title.upcase)
    end
  end
  
end
