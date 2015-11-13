# == Schema Information
#
# Table name: projects
#
#  id          :integer(4)      not null, primary key
#  parent_id   :integer(4)
#  lft         :integer(4)
#  rgt         :integer(4)
#  client_id   :integer(4)
#  name        :string(255)     not null
#  account     :string(255)
#  description :text
#  clockable   :boolean(1)      default(FALSE), not null
#  created_at  :datetime
#  updated_at  :datetime
#  billable    :boolean(1)      default(TRUE)
#  flat_rate   :boolean(1)      default(FALSE)
#


require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Project do

  # let :repository do "https://github.com/Awesome/McAwesome" end
  let :pivotal_id do 12345 end

  let :root_project do Project.root end

  it "should create a new instance given valid attributes" do
    FactoryGirl.create(:project)
  end

  it "should not be valid if has no parent" do
    FactoryGirl.build(:project, :parent_id => nil).should_not be_valid
  end

  it "should be valid if has parent" do
    FactoryGirl.build(:project, :parent_id => 1).should be_valid
  end

  it "without parent should be valid if its name is root " do
    FactoryGirl.build(:project, :parent_id => nil, :name => "root").should be_valid
  end

  it "should require a name" do
    FactoryGirl.build(:project, :name => nil).should_not be_valid
  end

  it "should save rates" do
    project = FactoryGirl.create(:project)
    project.rates.clear
    rate = FactoryGirl.create(:rate, :project => project)
    project.rates << rate
    project.save
    project.rates.size.should == 1
  end

  describe "before_save cascades" do
    describe "client" do
      before(:each) do
        @client = FactoryGirl.create(:client)
        @client2 = FactoryGirl.create(:client)
      end
      it "should return a project's client" do
        @leaf = FactoryGirl.create(:project, :client => @client)
        @leaf.client.should == @client
      end
      it "should return a project's parent's client if the project has no client" do
        @parent = FactoryGirl.create(:project, :client => @client)
        @leaf = FactoryGirl.create(:project, :client_id => nil, :parent => @parent)
        @leaf.client.should == @parent.client
      end
      it "should return a project's grandparent's client if the project and parent have no client" do
        @grandparent = FactoryGirl.create(:project, :client => @client, :name => 'GP')
        @parent = FactoryGirl.create(:project, :parent => @grandparent, :client_id => nil, :name => "P")
        @project = FactoryGirl.create(:project, :client_id => nil, :parent => @parent)
        @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
        @project.client.should == @client
      end
      it "should return a project's parent's client if the project has no client and the grandparent has a different client" do
        @grandparent = FactoryGirl.create(:project, :client => @client)
        @parent = FactoryGirl.create(:project, :parent => @grandparent, :client => @client2)
        @project = FactoryGirl.create(:project, :client_id => nil, :parent => @parent)
        @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
        @project.client.should == @parent.client
      end
    end
  end

  describe "repositories_source" do
    it "should return a project's parent if the project has no repositories" do
      @parent = FactoryGirl.create(:project, :with_repo)
      expect(FactoryGirl.create(:project, :parent => @parent).repositories_source).to eq(@parent)
    end
    it "should return a project's grandparent's if the project and parent have no repositories" do
      @grandparent = FactoryGirl.create(:project, :with_repo, :name => 'GP')
      @parent = FactoryGirl.create(:project, :parent => @grandparent, :name => "P")
      @project = FactoryGirl.create(:project, :parent => @parent)
      @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
      @project.repositories_source.should == @grandparent
    end
    it "should return a project's parent if the project has no repositories and the grandparent has different repositories" do
      @grandparent = FactoryGirl.create(:project)
      @gp_repo = FactoryGirl.create(:repository, project: @grandparent, url: "https://github.com/Awesome/NotAwesome")
      @parent = FactoryGirl.create(:project, :with_repo, :parent => @grandparent)
      @project = FactoryGirl.create(:project, :parent => @parent)
      @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
      @project.repositories_source.should == @parent

      @grandparent.reload.descendants.should include(@parent)
      @grandparent.reload.descendants.should include(@project)
    end
  end


  describe "cascades" do
    describe "account" do
      it "should return a project's client" do
        FactoryGirl.create(:project, :account => "account").account.should == "account"
      end
      it "should return a project's parent's client if the project has no client" do
        @parent = FactoryGirl.create(:project, :account => "account")
        FactoryGirl.create(:project, :account => nil, :parent => @parent).account.should == "account"
      end
      it "should return a project's grandparent's client if the project and parent have no client" do
        @grandparent = FactoryGirl.create(:project, :account => "account", :name => 'GP')
        @parent = FactoryGirl.create(:project, :parent => @grandparent, :account => nil, :name => "P")
        @project = FactoryGirl.create(:project, :account => nil, :parent => @parent)
        @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
        @project.account.should == "account"
      end
      it "should return a project's parent's client if the project has no client and the grandparent has a different client" do
        @grandparent = FactoryGirl.create(:project, :account => "account")
        @parent = FactoryGirl.create(:project, :parent => @grandparent, :account => "account2")
        @project = FactoryGirl.create(:project, :account => nil, :parent => @parent)
        @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
        @project.account.should == "account2"

        @grandparent.reload.descendants.should include(@parent)
        @grandparent.reload.descendants.should include(@project)
      end
    end

    describe "pivotal_id" do
      it "should return a project's pivotal ID" do
        FactoryGirl.create(:project, :pivotal_id => pivotal_id ).pivotal_id.should == pivotal_id
      end
      it "should return a project's parent's pivotal ID if the project has no pivotal ID" do
        @parent = FactoryGirl.create(:project, :pivotal_id => pivotal_id )
        FactoryGirl.create(:project, :pivotal_id => nil , :parent => @parent).pivotal_id.should == pivotal_id
      end
      it "should return a project's grandparent's pivotal ID if the project and parent have no pivotal ID" do
        @grandparent = FactoryGirl.create(:project, :pivotal_id => pivotal_id, :name => 'GP')
        @parent = FactoryGirl.create(:project, :parent => @grandparent, :pivotal_id => nil, :name => "P")
        @project = FactoryGirl.create(:project, :pivotal_id => nil, :parent => @parent)
        @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
        @project.pivotal_id.should == pivotal_id
      end
      it "should return a project's parent's pivotal ID if the project has no pivotal ID  and the grandparent has a different pivotal ID" do
        @grandparent = FactoryGirl.create(:project, :pivotal_id => 54321)
        @parent = FactoryGirl.create(:project, :parent => @grandparent, :pivotal_id => pivotal_id)
        @project = FactoryGirl.create(:project, :pivotal_id => nil, :parent => @parent)
        @project.ancestors.reverse.should == [ @parent, @grandparent, root_project ]
        @project.pivotal_id.should == pivotal_id

        @grandparent.reload.descendants.should include(@parent)
        @grandparent.reload.descendants.should include(@project)
      end
    end
  end
end
