module WorkUnitsHelper
  include ProjectsHelper

  def clocked_in?
    current_user.clocked_in? if current_user
  end

  def current_work_unit
    current_user.current_work_unit if current_user
  end

  def widget_links(work_unit)
    link_to( 'Edit', edit_work_unit_path(work_unit)) + " " +
    link_to('Delete', work_unit_path(work_unit), {:method => :delete, data: { confirm: "Are you sure?"} })
  end

  def project_selector(form)
    form.select(:project_id, project_options, {}, { :class => "project_selector"})
  end

  def work_unit_row_tag(work_unit, token = nil, cssclass = nil, &block)
    content_tag(:tr,
                 :id => token,
                 :class => ['work_unit', work_unit.annotated? ? nil : "needs-note" ] + [ cssclass ]
                ) do
      yield
    end
  end
end