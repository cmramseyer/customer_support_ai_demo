module ApplicationHelper
  def render_markdown(content)
    Commonmarker.to_html(content, options: {
      render: { escape: true },
      extension: { autolink: true, header_ids: nil, strikethrough: true, table: true, tasklist: true }
    }).html_safe
  end
end
