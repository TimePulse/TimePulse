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
    link_to('Delete', work_unit_path(work_unit), {:method => :delete, :confirm => "Are you sure?"})
  end

  def project_selector(form)
    form.select(:project_id,
    Project.where(:clockable => true).collect {|p| [project_name_with_client(p), p.id]}
    )
  end

end
