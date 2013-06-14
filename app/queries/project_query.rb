class ProjectQuery

  def find_for_project(project, options = {})

    if options[:exclusive]
      ids = project.id
    else
      ids = project.self_and_descendants.map{ |p| p.id }
    end
    @relation.where(:project_id => ids)

  end

end
