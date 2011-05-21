if Rails.env.development? or Rails.env.staging?
  def git_command(command)
    return `git --no-pager #{command} 2>&1`
  end
  GIT_REVISION = git_command('show --pretty=format:"%H" --quiet')[0..8]
  begin
    GIT_COMMIT_DATE = DateTime.parse(`git --no-pager show --pretty=format:"%ci" --quiet`)
    temp_tag = `git --no-pager describe 2>&1`
    if temp_tag =~ /fatal/
      GIT_TAG = "no tag"
    else
      GIT_TAG = temp_tag
    end
  rescue ArgumentError #can't parse date
    GIT_TAG = GIT_COMMIT_DATE = "N/A"
  end
end
