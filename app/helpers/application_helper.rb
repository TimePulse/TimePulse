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
end
