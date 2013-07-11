class ProjectActivityQuery < ProjectQuery

  def initialize(relation = Activity.scoped)
    @relation = relation
  end

end
