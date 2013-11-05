class WorkUnitBaseController < ApplicationController
  def find_work_unit_and_authenticate
    @work_unit = WorkUnit.find(params[:id])
    raise ArgumentError, 'Invalid work_unit id provided' unless @work_unit
    require_owner!(@work_unit.user)
  end
end