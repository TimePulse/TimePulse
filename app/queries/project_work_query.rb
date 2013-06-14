class ProjectWorkQuery < ProjectQuery

  def initialize(relation = WorkUnit.scoped)
    @relation = relation
  end

end
