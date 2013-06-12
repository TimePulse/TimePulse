class AddThirdReferenceToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :reference_3, :string
  end
end
