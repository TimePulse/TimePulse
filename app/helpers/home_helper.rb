module HomeHelper
  def project_headline(project)
    "Manual Time Entry: ".html_safe + short_name_with_client(project)
  end
end
