module HomeHelper
  def project_headline(project)
    "Dashboard: ".html_safe + short_name_with_client(project)
  end
end
