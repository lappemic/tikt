module ApplicationHelper
  def project_status_badge(project)
    badge_class = project.active? ? "paid" : "draft"
    tag.span(project.status.upcase, class: "badge badge--#{badge_class}")
  end
end
