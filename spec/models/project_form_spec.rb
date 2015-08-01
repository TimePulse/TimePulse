require 'spec_helper'

describe ProjectForm do
  let :project do
    FactoryGirl.create(:project, :with_rate, :with_repo, {clockable: false})
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
  
  context ", when find is called" do
    context "without attribute parameters," do
      let :project_form do
        ProjectForm.find(project.id)
      end
      
      it "assigns the project to the project form" do
        project_form.project.should == project
      end
      
      it "assigns the project's attributes to the project form" do
        project_form.name.should == project.name
        project_form.parent_id.should == project.parent.id
        project_form.clockable.should be_false
        project_form.archived.should == project.archived
        project_form.pivotal_id == project.pivotal_id
      end
        
      it "builds an extra rate" do
        expect(project_form.project.rates.length).to eq(project.rates.length + 1)
      end
      
    end
    
    context "with attribute parameters" do
      let :project_form do
        ProjectForm.find(project.id, valid_parameters)
      end
      
      it "assigns the project to the project form" do
        project_form.project.should == project
      end
      
      it "assigns the project's attributes to the project form" do
        project_form.archived.should == project.archived
        project_form.pivotal_id == project.pivotal_id
      end
      
      it "overwrites the projects attributes with the attribute parameters" do
        project_form.name.should == valid_parameters[:name]
        project_form.parent_id.should == valid_parameters[:parent_id]
        project_form.client_id.should == valid_parameters[:client_id]
        project_form.clockable.should == valid_parameters[:clockable]
      end
      
      it "does not build an extra rate" do
        expect(project_form.project.rates.length).to eq(project.rates.length)
      end
    end
  end
end
