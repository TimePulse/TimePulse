class ProjectWorkQuery < ProjectQuery

  def initialize(relation = WorkUnit.all)
    @relation = relation
  end

end