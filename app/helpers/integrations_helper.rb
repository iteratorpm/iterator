module IntegrationsHelper
  def integration_display_name(type)
    case type.to_sym
    when :github_enterprise then "GitHub Enterprise"
    when :bitbucket_server then "Bitbucket Server"
    when :gitlab_self_managed then "GitLab Self-Managed"
    when :generic then "Custom"
    else type.to_s.titleize
    end
  end

  def integration_description(type)
    case type.to_sym
    when :github, :github_enterprise then "Source control and code management platform"
    when :bitbucket, :bitbucket_server then "Source control and code management platform"
    when :gitlab, :gitlab_self_managed then "Source control and code management platform"
    when :jira then "Atlassian's issue-tracking product"
    when :zendesk then "Cloud-based customer support platform"
    when :concourse, :jenkins, :generic then "CI/CD Management"
    when :other then "Create your own custom integration"
    when :slack then "Team communication platform"
    when :campfire then "Web-based group chat tool"
    else "Integration with #{type.to_s.titleize}"
    end
  end
end
