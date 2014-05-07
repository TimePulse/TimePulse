class ProjectActivityQuery < ProjectQuery

  def initialize(relation = Activity.all)
    @relation = relation
  end

end
