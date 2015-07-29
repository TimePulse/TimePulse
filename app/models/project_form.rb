class ProjectForm
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attribute :parent_id, Integer
  attribute :client_id, Integer
  attribute :name, String
  attribute :account, String
  attribute :description, String
  attribute :clockable, Boolean
  attribute :billable, Boolean
  attribute :flat_rate, Boolean
  attribute :archived, Boolean
  attribute :pivotal_id, Boolean
  attribute :repositories_attributes, Hash
  attribute :rates_attributes, Hash
  
  attr_accessor :project, :repositories, :rates, :form_options
  
  validates :name, presence: true

  def self.find(id)
    project_form = self.new
    project = Project.find(id)
    project_form.project = project
    project_form.attributes = project.attributes
    if project.repositories
      project_form.repositories = project.repositories
    end
    if project.rates
      project_form.rates = project.rates
    end
    project_form
  end
  
  def set_defaults
    @project = Project.new
    self.attributes = project_defaults
    @repositories = [@project.repositories.new]
    @rates = [@project.rates.new]
  end
  
  def append_new_rate
    if @rates
      @rates = @rates.to_a << @project.rates.new
    else
      @rates = [@project.rates.new]
    end
  end
  
  def save
    @project ||= Project.new
    @project.assign_attributes(project_params)
    destroy_repositories
    build_repositories
    if valid?
      @project.save
      @repositories.each do |repo|
        repo.save
      end
      update_rates
    end

    unless project.errors.blank?
      @errors = project.errors
    end

    errors.blank?
  end
  
  private
  
  def destroy_repositories
    @project.repositories.destroy_all
  end
    
  def build_repositories
    if @repositories_attributes
      @repositories = []
      @repositories_attributes.values.each do |r|
        unless (r["url"].blank? || r["_destroy"] == '1')
          repo = Repository.create(url: r["url"])
          repo.project = @project
          @repositories << repo if repo.valid?
        end
      end
    end
  end
  
  def update_rates
    if @rates_attributes
      @rates_attributes.values.each do |r|
        if r["id"]
          rate = Rate.find(r["id"])
          if r["destroy"] == "1"
            rate.destroy
          else
            rate.update(name: r["name"], amount: r["amount"])
          end
        else
          unless r["destroy"] == "1"
            rate = Rate.create(name: r["name"], amount: r["amount"])
            rate.project = @project
            rate.save
          end
        end
      end
    end
  end
      
  def project_params
    {
      parent_id: @parent_id,
      client_id: @client_id,
      name: @name,
      account: @account,
      description: @description,
      clockable: @clockable,
      billable: @billable,
      flat_rate: @flat_rate,
      archived: @archived,
      pivotal_id: @pivotal
      }
  end

  def project_defaults
    {
      clockable: false,
      billable: true,
      flat_rate: false,
      archived: false,
      }
  end
end
