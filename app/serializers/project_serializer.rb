class ProjectSerializer < BaseSerializer
    attributes :id, :parent_id, :lft, :rgt, :client_id, :name, :account, :description,
      :clockable, :created_at, :updated_at, :billable, :flat_rate, :archived,
      :github_url, :pivotal_id
end