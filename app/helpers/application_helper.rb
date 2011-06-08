# Methods added to this helper will be available to all templates in the application.
require 'authenticated_system'
module ApplicationHelper
  include LogicalAuthz::Helper
  include AuthenticatedSystem

  def logged_in?
    !current_user.nil?
  end

  def admin?
    logged_in? and current_user.admin?
  end

  def current_project_label
    String.new.tap do |str|
      if current_project
        str << current_project.name
        str << "&nbsp;&nbsp;[#{current_project.client.name }]"  if current_project.client
      else
        str << "None Selected"
      end
      str.html_safe
    end
  end

  def clocked_in_project?(project)
    return true if current_work_unit && current_work_unit.project == project
  end

  def labeled_datepicker_field(form, field_name, options = {})
    options.reverse_merge!(:cssclass => :date_entry)
    fieldval =  form.object.send(field_name)
    value = fieldval ? fieldval.to_s(:long) : nil
    form.labeled_input(field_name, options.merge!(
      :class => options[:cssclass],
      :value => value
    ))
  end

  def labeled_datetimepicker_field(form, field_name, options = {})
    labeled_datepicker_field(form, field_name, options.merge!( :cssclass => :datetime_entry ))
  end
end
