module WorkUnitTools

  def find_user(klass, id)
    user = klass.find_by_id(id)
    unless user
      flash[:error] = "Could not find the specified #{klass.name.downcase}"
      redirect_to :back
    end
    return user
  end

  def add_work_units(object, work_unit_ids)
    if work_unit_ids
      object.work_units = []
      work_unit_ids.each do |id, bool|
        object.work_units << WorkUnit.find(id) if bool == "1"
      end
    end
  end

end
