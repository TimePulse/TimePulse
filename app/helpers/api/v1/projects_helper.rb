module Api
  module V1
    module ProjectsHelper

      def project_json_api(project)
        attributes = [
          :id,
          :name,
          :account,
          :description,
          :clockable,
          :billable,
          :flat_rate,
          :archived,
          :github_url,
          :pivotal_id,
          :created_at,
          :updated_at
        ].each_with_object({}) do |field, hash|
          hash[field] = project.read_attribute(field)
        end

        attributes[:links] = {
          :lft => project.lft,
          :rgt => project.rgt,
          :parent => project.parent_id,
          :client => project.client_id
        }

        attributes
      end

    end
  end
end