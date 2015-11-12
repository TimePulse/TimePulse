require 'spec_helper'

describe AnnotationsController do
  let! :annotation do
    FactoryGirl.create(:activity)
  end

  describe "for an unlogged in user" do
    it "cannot create new annotation" do
      post :create
      verify_authorization_unsuccessful
    end

    it "cannot delete an annotation" do
      delete :destroy, id: annotation.id
      verify_authorization_unsuccessful
    end
  end

  describe "for a signed-in user" do
    let :user do
      FactoryGirl.create(:user)
    end

    before :each do
      sign_in user
    end

    describe "#create" do
      let :valid_params do
        {description: "A Description",
          work_unit_id: work_unit_id,
          project_id: project_id,
          source: "User",
          action: "Annotation",
          user_id: user.id,
          }
      end

      describe "with a work unit in params (not in progress)" do
        let :work_unit do
          FactoryGirl.create(:work_unit)
        end
        let :work_unit_id do
          work_unit.id.to_s
        end
        let :project_id do
          work_unit.project.id.to_s
        end

        it "creates a new annotation" do
          lambda do
            post :create, activities: valid_params, format: "js"
          end.should change(Activity, :count).by(1)
        end

        it "associates the annotation with the given work unit" do
          post :create, activities: valid_params, format: "js"

          expect(work_unit.activities.last).
            to eq(Activity.last)
        end

        it "gives the new annotation the same time as the work unit's stop time" do
          post :create, activities: valid_params, format: "js"

          expect(work_unit.activities.last).
            to eq(Activity.last)
        end
      end

      describe "without a work unit in params" do
        let :work_unit_id do
          ""
        end

        describe "with a current work unit" do
          let :current_work_unit do
            FactoryGirl.create(:in_progress_work_unit, user: user)
          end
          let :project_id do
            current_work_unit.project.id.to_s
          end

          it "creates a new activity" do
            lambda do
              post :create, activities: valid_params, format: "js"
            end.should change(Activity, :count).by(1)
          end

          it "associates the new activity with the current work unit" do
            post :create, activities: valid_params, format: "js"

            expect(current_work_unit.activities.last).
              to eq(Activity.last)
          end

          # Unsure how to properly test setting time to "now"
          it "sets the activity's time" do
            post :create, activities: valid_params, format: "js"

            expect(Activity.last.time).to_not be_nil
          end
        end

        describe "without a current work unit" do
          let :project_id do
            FactoryGirl.create(:project).id
          end

          it "creates a new activity" do
            lambda do
              post :create, activities: valid_params, format: "js"
            end.should change(Activity, :count).by(1)
          end

          it "does not associate the new activity with a work unit" do
            post :create, activities: valid_params, format: "js"

            expect(Activity.last.work_unit).to be_nil
          end

          it "does not set a time" do
            post :create, activities: valid_params, format: "js"

            expect(Activity.last.time.blank?).to eq(true)
          end

        end
      end
    end

    describe "#destroy" do

      it "deletes the annotation from the database" do
        expect do
          delete :destroy, id: annotation.id, format: "js"
        end.to change(Activity, :count).by(-1)
      end

      it "makes the activity unfindable in the database" do
        delete :destroy, id: annotation.id, format: "js"
        expect {Activity.find(annotation.id)}.to raise_error(ActiveRecord::RecordNotFound)
      end

    end
  end
end
