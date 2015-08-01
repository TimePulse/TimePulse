require 'spec_helper'

describe ProjectsController do
  let :project do
    FactoryGirl.create(:project, :with_rate)
  end
  
  let :client do
    FactoryGirl.create(:client)
  end
  
  let :valid_parameters do
    {
      name: "Naamen, Namor & Namm",
      client_id: client.id,
      parent_id: project.id,
      clockable: true
      }
  end
  
  context ", when new is called" do
    context "without attribute paramaters," do
      context "and without the set defaults option" do

        it "creates a new, blank project form" do
          project_form = ProjectForm.new
          expect(project_form.project).to be_nil
          expect(project_form.clockable).to be_nil
          expect(project_form.name).to be_nil
        end
      end
      
      context "but with the set defaults option," do
        let :project_form do
          ProjectForm.new(nil, set_defaults: true)
        end
        
        it "creates a new project" do
          project_form.project.should be_new_record
        end
        
        it "creates a new rate" do
          expect(project_form.project.rates.length).to equal(1)
          project_form.project.rates.first.should be_new_record
        end
        
        it "creates a new repository" do
          expect(project_form.project.repositories.length).to equal(1)
          project_form.project.repositories.first.should be_new_record
        end
          
        it "sets default attributes" do
          project_form.clockable.should be_false
          project_form.billable.should be_true
          project_form.flat_rate.should be_false
          project_form.archived.should be_false
        end
      end  
    end
    
    context "with attribute parameters" do
      context "but no other options," do
        let :project_form do
          ProjectForm.new(valid_parameters)
        end

        it "assigns parameters to the new project form" do
          project_form.name.should == valid_parameters[:name]
          project_form.client_id.should == valid_parameters[:client_id]
          project_form.parent_id.should == valid_parameters[:parent_id]
          project_form.clockable.should == valid_parameters[:clockable]
        end
        
        it "does not create a new project" do
          expect(project_form.project).to be_nil
        end
      end

      context "and set defaults option," do
        let :project_form do
          ProjectForm.new(valid_parameters, set_defaults: true)
        end

        it "creates a new project" do
          expect(project_form.project.new_record?).to be_true
        end
        
        it "assigns default parameters" do
          project_form.billable.should be_true
          project_form.flat_rate.should be_false
          project_form.archived.should be_false
        end

        it "overwrites default parameters" do
          project_form.clockable.should be_true
        end
        
        it "assigns passed-in parameters" do
          project_form.name.should == valid_parameters[:name]
          project_form.client_id.should == valid_parameters[:client_id]
          project_form.parent_id.should == valid_parameters[:parent_id]
        end
      end
    end
  end
end
          

#       end
#   end

#       it "assigns the requested project as @project" do
#         @project.rates.clear
#         get :edit, :id => @project.id
#         verify_authorization_successful
#         assigns[:project_form][:project].should ==  @project
#         assigns[:project_form][:project].rates.size.should == 1
#       end
#     describe "POST create" do

#       describe "with valid params" do
#         it "assigns a newly created project as @project" do
#           post :create, project_form: { name: 'Cool Project', parent_id: @project.id, clockable: false }
#           verify_authorization_successful
#           assigns[:project_form][:project].should be_a(Project)
#           assigns[:project_form][:project].should_not be_new_record
#           assigns[:project_form][:project].parent.should == @project
#         end

#         it "redirects to the created project" do
#           post :create, project_form:  { name: 'Cool Project', parent_id: @project.id, clockable: false }
#           verify_authorization_successful
#           response.should redirect_to(project_url(assigns[:project_form][:project]))
#         end
#       end

#       describe "with invalid params" do
#         it "assigns a newly created but unsaved project as @project" do
#           post :create, project_form: { name: '' }
#           verify_authorization_successful
#           assigns[:project_form][:project].should be_a(Project)
#           assigns[:project_form][:project].should be_new_record
#           assigns[:project_form][:project].rates.size.should == 1
#         end

#         it "re-renders the 'new' template" do
#           post :create, project_form: { name: '' }
#           verify_authorization_successful
#           response.should render_template('new')
#         end
#       end

#     end

#     describe "PUT update" do

#       describe "with valid params" do
#         it "updates the requested project" do
#           lambda do
#             put :update, id: @project.id, project_form: {name: 'new name'}
#             verify_authorization_successful
#           end.should change{ @project.reload.name }.to('new name')
#         end

#         it "assigns the requested project as @project" do
#           put :update, id: @project.id, project_form: {name: 'new name'}
#           verify_authorization_successful
#           assigns[:project_form][:project].should == @project
#         end

#         it "redirects to the project" do
#           put :update, id: @project.id, project_form: {name: 'new name'}
#           verify_authorization_successful
#           response.should redirect_to(projects_url)
#         end

#         it "can set the project to archived" do
#           put :update, id: @project.id, project_form: {archived: true}
#           @project.reload.should be_archived
#         end

#         it "can set the project rates" do
#           put :update, id: @project.id, project_form: {rates_attributes: {"0" => {name: "Senior Captain", amount: "175" }}}
#           @project.reload.rates.count.should == 2
#           @project.reload.rates[1].name.should == "Senior Captain"
#         end

#       end

#       describe "with invalid params" do
#         it "doesn't change the record" do
#           lambda do
#             put :update, id: @project.id, project_form: {name: nil }
#             verify_authorization_successful
#           end.should_not change{ @project.reload }
#         end

#         it "assigns the project as @project" do
#           @project.rates.clear
#           put :update, id: @project.id, project_form: {name: nil }
#           verify_authorization_successful
#           assigns[:project_form][:project].should == @project
#           assigns[:project_form][:project].rates.size.should == 1
#         end

#         it "re-renders the 'edit' template" do
#           put :update, id: @project.id, project_form: {name: nil }
#           verify_authorization_successful
#           response.should render_template('edit')
#         end
#       end

#     end
