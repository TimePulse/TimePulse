class AnnotationMapper

  def initialize(json)
    @source_json = json
    @source_hash = JSON.parse(json)
  end


  def save
    @annotation = Activity.new(@source_hash)
    @annotation.save
    @annotation
  end
end