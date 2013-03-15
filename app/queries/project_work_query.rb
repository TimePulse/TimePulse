class ProjectWorkQuery

  def initialize(relation = WorkUnit.scoped)
    @relation = relation
  end

  def find_for_project(project, exclusive = true)

    if exclusive
      ids = project.id
    else
      ids = project.self_and_descendants.map{ |p| p.id }
    end
    @relation.where(:project_id => ids)
    
  end

end
