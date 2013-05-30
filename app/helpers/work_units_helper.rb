module WorkUnitsHelper
  include ProjectsHelper

  def clocked_in?
    current_user.clocked_in? if current_user
  end

  def current_work_unit
    current_user.current_work_unit if current_user
  end

  def tooltip_for(work_unit, token)
    content_tag( :div, :id => "tooltip_for_#{token}", :class => "lrd-tooltip") do
      content_tag(:dl) do
         [
          ["Project:",    short_name_with_client(work_unit.project)],
          ["Notes:",      work_unit.notes],
          ["Hours:",      work_unit.hours],
          ["Started:",    work_unit.start_time.nil? ? "-" : work_unit.start_time.to_s(:short_datetime)],
          ["Finished:",   work_unit.stop_time.nil? ? "-" : work_unit.stop_time.to_s(:short_datetime)]
          ].map{ |line| "<dt>#{line[0]}</dt><dd>#{line[1]}</dd>".html_safe }.join().html_safe
      end
    end
  end

  def commit_tooltip_for(commit, token)
    content_tag( :div, :id => "tooltip_for_#{token}", :class => "lrd-tooltip") do
      content_tag(:dl) do
         [
          ["Project:",    short_name_with_client(commit.project)],
          ["Message:",      commit.description],
          ["Commit ID:",      commit.reference_1],
          ["Branch",    commit.reference_2],
          ["Time:",   commit.time.to_s(:short_datetime)]
          ].map{ |line| "<dt>#{line[0]}</dt><dd>#{line[1]}</dd>".html_safe }.join().html_safe
      end
    end
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
