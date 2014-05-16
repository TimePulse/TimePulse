class WorkUnitMapper

  def initialize(json)
    @source_json = json
    @source_hash = JSON.parse(json)
  end


  def save
    @work_unit = WorkUnit.new(@source_hash)
    @work_unit.save
    @work_unit
  end
end