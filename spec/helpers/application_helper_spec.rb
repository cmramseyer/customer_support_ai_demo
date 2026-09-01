require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  it "renders GitHub-flavored Markdown" do
    rendered = helper.render_markdown("# Refund policy\n\n- Returns within 30 days\n- Original receipt required")

    expect(rendered).to include("<h1>Refund policy</h1>", "<ul>", "<li>Returns within 30 days</li>")
  end

  it "escapes raw HTML" do
    rendered = helper.render_markdown("<script>alert('unsafe')</script>")

    expect(rendered).to include("&lt;script&gt;")
    expect(rendered).not_to include("<script>")
  end
end
