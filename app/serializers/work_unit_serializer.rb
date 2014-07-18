class WorkUnitSerializer < ActiveModel::Serializer
  attributes :id, :start_time, :stop_time, :hours, :notes, :billable
end
